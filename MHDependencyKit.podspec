Pod::Spec.new do |s|

  s.name         = "MHDependencyKit"
  s.version      = "1.0.0"
  s.source       = { :git => "https://github.com/KoCMoHaBTa/MHDependencyKit.git", :tag => "#{s.version}" }
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "Milen Halachev"
  s.summary      = "iOS Swift library that helps resolves dependencies between objects and view controllers in a workflow manner."
  s.homepage     = "https://github.com/KoCMoHaBTa/MHDependencyKit"

  s.description  = <<-DESC
                        The main goal of the library is to simplify the depdendency resolution between UIViewController objects, especially when using storyboard segues. The approach used in protocol oriented, where dependencies are defined as protocols and the view controllers just implement them in order to declare their needs. The DependencyCoordinator, once setup at the app's entry point, will automatically resolve all dependencies between any view controller obejcts, no matter where it appears in the workflow.
                    DESC

  s.swift_version = "4.2"
  s.ios.deployment_target = "8.0"

  s.source_files  = "MHDependencyKit/**/*.swift", "MHDependencyKit/MHDependencyKit.h"
  s.public_header_files = "MHDependencyKit/MHDependencyKit.h"

end
