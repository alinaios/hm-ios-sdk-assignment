#!/usr/bin/env ruby

require "fileutils"

root = File.expand_path("..", __dir__)
project = File.join(root, "Frameworks/ImageProcessorProject/ImageProcessor.xcodeproj")
device_archive = File.join(root, "Build/ImageProcessorFramework-iOS.xcarchive")
simulator_archive = File.join(root, "Build/ImageProcessorFramework-Simulator.xcarchive")
output = File.join(root, "Frameworks/ImageProcessor.xcframework")

FileUtils.rm_rf(device_archive)
FileUtils.rm_rf(simulator_archive)
FileUtils.rm_rf(output)

def run(command)
  puts command.join(" ")
  system(*command) || abort("Command failed")
end

run([
  "xcodebuild",
  "archive",
  "-project", project,
  "-scheme", "ImageProcessor",
  "-destination", "generic/platform=iOS",
  "-archivePath", device_archive,
  "SKIP_INSTALL=NO",
  "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
])

run([
  "xcodebuild",
  "archive",
  "-project", project,
  "-scheme", "ImageProcessor",
  "-destination", "generic/platform=iOS Simulator",
  "-archivePath", simulator_archive,
  "SKIP_INSTALL=NO",
  "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
])

run([
  "xcodebuild",
  "-create-xcframework",
  "-framework", File.join(device_archive, "Products/Library/Frameworks/ImageProcessor.framework"),
  "-framework", File.join(simulator_archive, "Products/Library/Frameworks/ImageProcessor.framework"),
  "-output", output
])
