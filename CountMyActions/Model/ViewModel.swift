/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's main view model.
*/

import SwiftUI
import CreateMLComponents
import AsyncAlgorithms
import Vision
import CoreML
/// - Tag: ViewModel
class ViewModel: ObservableObject {

    /// The full-screen view that presents the pose on top of the video frames.
    @Published var liveCameraImageAndPoses: (image: CGImage, poses: [Pose])?

    /// The user-visible value of the repetition count.
    var uiCount: Float = 0.0
    var calories: Float = 0.0
    
    private var displayCameraTask: Task<Void, Error>?

    private var predictionTask: Task<Void, Error>?

    /// Stores the predicted action repetition count in the last window.
    private var lastCumulativeCount: Float = 0.0

    /// An asynchronous channel to divert the pose stream for another consumer.
    private let poseStream = AsyncChannel<TemporalFeature<[Pose]>>()
    
    /// A Create ML Components transformer to extract human body poses from a single image or a video frame.
    /// - Tag: poseExtractor
    private let poseExtractor = HumanBodyPoseExtractor()
    
    /// The camera configuration to define the basic camera position, pixel format, and resolution to use.
    private var configuration = VideoReader.CameraConfiguration()
    
    /// The counter to count action repetitions from a pose stream.
    private let actionCounter = ActionCounter()// MARK: - View Controller Events
    
    var currentExercise: String = ""
    
    var isPhaseOne = false
    
    var calorieIncrement: Float = 0
    
    var theTime: CFAbsoluteTime = 0
    /// Configures the main view after it loads.
    /// Starts the video-processing pipeline.
    func initialize(exercise: String, cal: Float) {
        startVideoProcessingPipeline()
        currentExercise = exercise
        
        calorieIncrement = Float(cal)
    }
    
    func stopVideoProcessing() {

      // Cancel any existing tasks
      displayCameraTask?.cancel()
      predictionTask?.cancel()

      // Clear the tasks
      displayCameraTask = nil
      predictionTask = nil

      // Reset state
      uiCount = 0
      lastCumulativeCount = 0

      // Clear any cached images
      liveCameraImageAndPoses = nil
    }
    
    func getExerciseInfo(exerciseName: String) -> (workoutType: String, details: [String: Any])? {
        let workouts: [String: [String: [String: Any]]] = [
            "Yoga": Yoga.exercises,
            "Warmup": Warmup.exercises,
            "HardWorkout": HardWorkout.exercises
        ]

        for (workoutType, exercises) in workouts {
            if let exerciseDetails = exercises[exerciseName] {
                return (workoutType, exerciseDetails)
            }
        }
        
        return nil
    }



// MARK: - Button Events

    /// Toggles the view between the front- and back-facing cameras.
    func onCameraButtonTapped() {
        toggleCameraSelection()

        // Reset the count.
        uiCount = 0.0

        // Restart the video processing.
        startVideoProcessingPipeline()
    }

// MARK: - Helper methods

    /// Change the camera toggle positions.
    func toggleCameraSelection() {
        if configuration.position == .front {
            configuration.position = .back
        } else {
            configuration.position = .front
        }
    }
    
    /// Start the video-processing pipeline by displaying the poses in the camera frames and
    /// starting the action repetition count prediction stream.
    func startVideoProcessingPipeline() {

        if let displayCameraTask = displayCameraTask {
            displayCameraTask.cancel()
        }

        displayCameraTask = Task {
            // Display poses on top of each camera frame.
            try await self.displayPoseInCamera()
        }

        if predictionTask == nil {
            predictionTask = Task {
                // Predict the action repetition count.
                try await self.predictCount()
            }
        }
    }
    
    func angleBetweenThreePoints(center: CGPoint, point1: CGPoint, point2: CGPoint) -> CGFloat {
        let vector1 = CGVector(dx: point1.x - center.x, dy: point1.y - center.y)
        let vector2 = CGVector(dx: point2.x - center.x, dy: point2.y - center.y)
        let dotProduct = vector1.dx * vector2.dx + vector1.dy * vector2.dy
        let magnitudeProduct = sqrt(vector1.dx * vector1.dx + vector1.dy * vector1.dy) * sqrt(vector2.dx * vector2.dx + vector2.dy * vector2.dy)
        let cosineAngle = dotProduct / magnitudeProduct
        let angleInRadians = acos(cosineAngle)
        let angleInDegrees = angleInRadians * 180 / .pi
        return angleInDegrees
    }
    
    func distanceBetweenPoints(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let xDistance = point2.x - point1.x
        let yDistance = point2.y - point1.y
        let distance = sqrt(xDistance * xDistance + yDistance * yDistance)
        return distance
    }
    
    /// Display poses on top of each camera frame.
    func displayPoseInCamera() async throws {
        // Start reading the camera.
        let frameSequence = try await VideoReader.readCamera(
            configuration: configuration
        )
        var lastTime = CFAbsoluteTimeGetCurrent()

        for try await frame in frameSequence {

            if Task.isCancelled {
                return
            }

            // Extract poses in every frame.
            let poses = try await poseExtractor.applied(to: frame.feature)

            // Send poses into another pose stream for additional consumers.
            await poseStream.send(TemporalFeature(id: frame.id, feature: poses))

            // Calculate poses from the image frame and display both.
            if let cgImage = CIContext()
                .createCGImage(frame.feature, from: frame.feature.extent) {
                
                /**
                    Check if there is a flamingo pose
                 */
                if currentExercise == "Flamingo" {
                    if let firstPose = poses.first {
                        if let rightShoulder = firstPose.keypoints[.rightShoulder],
                           let rightElbow = firstPose.keypoints[.rightElbow],
                           let rightWrist = firstPose.keypoints[.rightWrist],
                           //let leftHip = firstPose.keypoints[.leftHip],
                           let rightHip = firstPose.keypoints[.rightHip],
                           let rightKnee = firstPose.keypoints[.rightKnee],
                           let rightAnkle = firstPose.keypoints[.rightAnkle] {
                            
                            // Calculate the necessary angles for the flamingo pose
                            let shoulderAngle = angleBetweenThreePoints(center: rightElbow.location, point1: rightShoulder.location, point2: rightWrist.location)
                            let hipAngle = angleBetweenThreePoints(center: rightKnee.location, point1: rightHip.location, point2: rightAnkle.location)
                            
                            // Check if the angles meet the criteria for the flamingo pose
                            let isFlamingoPose = shoulderAngle < 45 && hipAngle < 45
                            //print(theTime, lastTime)
                            if isFlamingoPose && lastTime - theTime > 1{
                                // The person is doing the flamingo pose
                                uiCount += 1
                                calories += calorieIncrement
                                theTime = lastTime
                                print("Flamingo Pose detected!")
                            }
                        }
                    }
                }
                /**
                    Check if there is a Chair Pose
                 */
                if currentExercise == "Chair Pose" {
                    if let firstPose = poses.first {
                        if let rightHip = firstPose.keypoints[.rightHip],
                           let leftHip = firstPose.keypoints[.leftHip],
                           let rightKnee = firstPose.keypoints[.rightKnee],
                           let leftKnee = firstPose.keypoints[.leftKnee],
                           let rightAnkle = firstPose.keypoints[.rightAnkle],
                           let leftAnkle = firstPose.keypoints[.leftAnkle],
                           let leftShoulder = firstPose.keypoints[.leftShoulder],
                           let rightShoulder = firstPose.keypoints[.rightShoulder],
                            let leftElbow = firstPose.keypoints[.leftElbow],
                            let rightElbow = firstPose.keypoints[.rightElbow],
                            let leftWrist = firstPose.keypoints[.leftWrist],
                            let rightWrist = firstPose.keypoints[.rightWrist] {
                            
                            
                            // Calculate the necessary angles for the wall sit
                            let rightKneeAngle = angleBetweenThreePoints(center: rightKnee.location, point1: rightHip.location, point2: rightAnkle.location)
                            let leftKneeAngle = angleBetweenThreePoints(center: leftKnee.location, point1: leftHip.location, point2: leftAnkle.location)
                            let leftArmAngle = angleBetweenThreePoints(center: leftElbow.location, point1: leftShoulder.location, point2: leftWrist.location)
                            let rightArmAngle = angleBetweenThreePoints(center: rightElbow.location, point1: rightShoulder.location, point2: rightWrist.location)
                            
                            // Check if the angles meet the criteria for the wall sit
                            let isWallSit = rightKneeAngle < 90 && leftKneeAngle < 90 && rightKneeAngle > 45 && leftKneeAngle > 45 && !rightKneeAngle.isNaN && !leftKneeAngle.isNaN && leftArmAngle > 140 && rightArmAngle > 140 && (rightElbow.location.y > rightShoulder.location.y || leftElbow.location.y > leftShoulder.location.y)
                            
                            if isWallSit && lastTime - theTime > 1 {
                                // The person is doing a wall sit
                                print("Chair Pose detected!", rightKneeAngle, leftKneeAngle)

                                uiCount += 1
                                calories += calorieIncrement
                                
                            }
                        }
                    }
                }
                /**
                    Check if there is a Planks Pose
                 */
                if currentExercise == "Planks" {
                    if let firstPose = poses.first {
                            if let knee = firstPose.keypoints[.rightKnee],
                               let root = firstPose.keypoints[.root],
                               let neck = firstPose.keypoints[.neck] {
                                
                                // Calculate the absolute differences between the y-values
                                let kneeRootDiff = abs(knee.location.y - root.location.y)
                                let rootNeckDiff = abs(root.location.y - neck.location.y)
                                
                                print(kneeRootDiff, rootNeckDiff)

                                // Check if the differences are within the threshold
                                if kneeRootDiff < 0.02 && rootNeckDiff < 0.09 && lastTime - theTime > 1 {
                                    // The person is in a horizontal position
                                    uiCount += 1
                                    calories += calorieIncrement
                                    print("Horizontal position detected!")
                                }
                                
                            }
                    }
                }
                
                /**
                    Check if there is a Squat Pose
                 */
                if currentExercise == "Squat" {
                    if let firstPose = poses.first {
                        if let rightKnee = firstPose.keypoints[.rightKnee],
                           let root = firstPose.keypoints[.root],
                           let rightHip = firstPose.keypoints[.rightHip],
                           let rightAnkle = firstPose.keypoints[.rightAnkle],
                           let neck = firstPose.keypoints[.neck] {
                            
                            // Calculate the absolute differences between the y-values
                            let kneeRootDiff = abs(rightKnee.location.y - root.location.y)
                            let rootNeckDiff = abs(root.location.y - neck.location.y)
                            let legAngle = angleBetweenThreePoints(center: rightKnee.location, point1: rightHip.location, point2: rightAnkle.location)
                            
                            print(kneeRootDiff, rootNeckDiff)

                            // Set thresholds to consider the person as standing straight
                            let standingThreshold = 0.2  // Adjust this value according to your use case
                            let standing = kneeRootDiff < standingThreshold && rootNeckDiff < standingThreshold && kneeRootDiff > 0.1 && rootNeckDiff > 0.1
                            // Check if the differences are within the threshold
                            print(kneeRootDiff, rootNeckDiff)
                            if standing && !isPhaseOne {
                                // The person is in a standing position
                                isPhaseOne.toggle()
                                print("Standing position detected!")
                            } else if !standing && isPhaseOne && legAngle < 80{
                                uiCount += 1
                                calories += calorieIncrement
                                isPhaseOne.toggle()
                            }
                        }
                    }
                }
                
                await display(image: cgImage, poses: poses)
            }

            // Frame rate debug information.
            //print(String(format: "Frame rate %2.2f fps", 1 / (CFAbsoluteTimeGetCurrent() - lastTime)))
            lastTime = CFAbsoluteTimeGetCurrent()
        }
    }
    
    /// Predict the action repetition count.
    func predictCount() async throws {
        
        // Create an asynchronous temporal sequence for the pose stream.
        let poseTemporalSequence = AnyTemporalSequence<[Pose]>(poseStream, count: nil)

        // Apply the repetition-counting transformer pipeline to the incoming pose stream.
        let finalResults = try await actionCounter.count(poseTemporalSequence)

        var lastTime = CFAbsoluteTimeGetCurrent()
        for try await item in finalResults {

            if Task.isCancelled {
                return
            }

            let currentCumulativeCount = item.feature
            // Observe each predicted count (cumulative) and compare it to the previous result.
            if currentCumulativeCount - lastCumulativeCount <= 0.001 {
                // Reset the UI counter to 0 if the cumulative count isn't increasing.
                //uiCount = 0.0
            }

            // Add the incremental count to the UI counter.
            if ((currentExercise == "Russian Twist" || currentExercise == "Jumping Jacks" || currentExercise == "Weight Lifting") && currentCumulativeCount - lastCumulativeCount > 0.001 && lastTime - theTime > 0.4) {
                uiCount += 1
                calories += calorieIncrement
                theTime = lastTime
            }
            //uiCount += currentCumulativeCount - lastCumulativeCount

            // Counter debug information.
            /**
            print("""
                    Cumulative count \(currentCumulativeCount), last count \(lastCumulativeCount), \
                    incremental count \(currentCumulativeCount - lastCumulativeCount), UI count \(uiCount)
                    """)
             */
            // Update and store the last predicted count.
            lastCumulativeCount = currentCumulativeCount

            // Prediction rate debug information.
            //print(String(format: "Count rate %2.2f fps", 1 / (CFAbsoluteTimeGetCurrent() - lastTime)))
            lastTime = CFAbsoluteTimeGetCurrent()
        }
        
    }

    /// Updates the user interface's image view with the rendered poses.
    /// - Parameters:
    ///   - image: The image frame from the camera.
    ///   - poses: The detected poses to render onscreen.
    /// - Tag: display
    @MainActor func display(image: CGImage, poses: [Pose]) {
        self.liveCameraImageAndPoses = (image, poses)
    }
}
