#!/usr/bin/env ruby

require "xcodeproj"

PROJECT_PATH = "HMProductDemo.xcodeproj"

project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.compatibility_version = "Xcode 16.0"

def group(project, name, path = name)
  project.main_group.find_subpath(path, true).tap do |group|
    group.name = name
    group.source_tree = "<group>"
  end
end

app_group = group(project, "HMProductDemo")
tests_group = group(project, "HMProductDemoTests")
ui_tests_group = group(project, "HMProductDemoUITests")
packages_group = group(project, "Packages")
frameworks_group = group(project, "Frameworks")

app = project.new_target(:application, "HMProductDemo", :ios, "26.0")
unit_tests = project.new_target(:unit_test_bundle, "HMProductDemoTests", :ios, "26.0")
ui_tests = project.new_target(:ui_test_bundle, "HMProductDemoUITests", :ios, "26.0")

unit_tests.add_dependency(app)
ui_tests.add_dependency(app)

def add_sources(target, group, paths)
  paths.each do |path|
    parent = group
    File.dirname(path).split("/").drop(1).each do |folder|
      parent = parent.find_subpath(folder, true)
      parent.name = folder
      parent.source_tree = "<group>"
    end

    file = parent.new_file(path)
    target.add_file_references([file])
  end
end

add_sources(
  app,
  app_group,
  Dir["HMProductDemo/**/*.swift"].sort
)
add_sources(
  unit_tests,
  tests_group,
  Dir["HMProductDemoTests/**/*.swift"].sort
)
add_sources(
  ui_tests,
  ui_tests_group,
  Dir["HMProductDemoUITests/**/*.swift"].sort
)

local_package = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
local_package.relative_path = "Packages/ProductClient"
project.root_object.package_references << local_package
packages_group.new_file("Packages/ProductClient")

product_client_dependency = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
product_client_dependency.product_name = "ProductClient"
product_client_dependency.package = local_package

[app, unit_tests].each do |target|
  target.package_product_dependencies << product_client_dependency
  build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
  build_file.product_ref = product_client_dependency
  target.frameworks_build_phase.files << build_file
end

xcframework = frameworks_group.new_file("Frameworks/ImageProcessor.xcframework")
app.frameworks_build_phase.add_file_reference(xcframework)

embed_frameworks = app.new_copy_files_build_phase("Embed Frameworks")
embed_frameworks.dst_subfolder_spec = "10"
embed_file = embed_frameworks.add_file_reference(xcframework)
embed_file.settings = { "ATTRIBUTES" => ["CodeSignOnCopy", "RemoveHeadersOnCopy"] }

project.targets.each do |target|
  target.build_configurations.each do |config|
    settings = config.build_settings
    settings["IPHONEOS_DEPLOYMENT_TARGET"] = "26.0"
    settings["SWIFT_VERSION"] = "6.0"
    settings["SWIFT_STRICT_CONCURRENCY"] = "complete"
    settings["CLANG_ENABLE_MODULES"] = "YES"
    settings["ENABLE_USER_SCRIPT_SANDBOXING"] = "YES"
  end
end

app.build_configurations.each do |config|
  settings = config.build_settings
  settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.hm.assignment.HMProductDemo"
  settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
  settings["GENERATE_INFOPLIST_FILE"] = "YES"
  settings["INFOPLIST_KEY_UILaunchScreen_Generation"] = "YES"
  settings["MARKETING_VERSION"] = "1.0"
  settings["CURRENT_PROJECT_VERSION"] = "1"
  settings["TARGETED_DEVICE_FAMILY"] = "1,2"
  settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = ""
end

unit_tests.build_configurations.each do |config|
  settings = config.build_settings
  settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.hm.assignment.HMProductDemoTests"
  settings["GENERATE_INFOPLIST_FILE"] = "YES"
  settings["TEST_HOST"] = "$(BUILT_PRODUCTS_DIR)/HMProductDemo.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/HMProductDemo"
  settings["BUNDLE_LOADER"] = "$(TEST_HOST)"
end

ui_tests.build_configurations.each do |config|
  settings = config.build_settings
  settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.hm.assignment.HMProductDemoUITests"
  settings["GENERATE_INFOPLIST_FILE"] = "YES"
  settings["TEST_TARGET_NAME"] = "HMProductDemo"
end

project.save

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.add_test_target(unit_tests)
scheme.add_test_target(ui_tests)
scheme.set_launch_target(app)
scheme.save_as(PROJECT_PATH, "HMProductDemo", true)
