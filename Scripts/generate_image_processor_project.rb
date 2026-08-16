#!/usr/bin/env ruby

require "xcodeproj"

project_path = "Frameworks/ImageProcessorProject/ImageProcessor.xcodeproj"
project = Xcodeproj::Project.new(project_path)
project.root_object.compatibility_version = "Xcode 16.0"

source_group = project.main_group.new_group("ImageProcessor")
source_group.source_tree = "<group>"
source_file = source_group.new_file("../ImageProcessorSource/Sources/ImageProcessor/ImageProcessor.swift")

target = project.new_target(:framework, "ImageProcessor", :ios, "26.0")
target.add_file_references([source_file])

target.build_configurations.each do |config|
  settings = config.build_settings
  settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.hm.assignment.ImageProcessor"
  settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
  settings["GENERATE_INFOPLIST_FILE"] = "YES"
  settings["IPHONEOS_DEPLOYMENT_TARGET"] = "26.0"
  settings["SWIFT_VERSION"] = "6.0"
  settings["SWIFT_STRICT_CONCURRENCY"] = "complete"
  settings["SKIP_INSTALL"] = "NO"
  settings["BUILD_LIBRARY_FOR_DISTRIBUTION"] = "YES"
  settings["DEFINES_MODULE"] = "YES"
end

project.save

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.save_as(project_path, "ImageProcessor", true)
