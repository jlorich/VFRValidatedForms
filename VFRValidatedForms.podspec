Pod::Spec.new do |s|
  s.name         = "VFRValidatedForms"
  s.version      = "0.0.1"
  s.summary      = "Easy iOS text field validation"
  s.homepage     = "https://github.com/jlorich/VFRValidatedForms.git"
  s.license      = "MIT"
  s.author       = { "Joseph Lorich" => "joseph@lorich.me" }
  s.platform     = :ios
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/jlorich/VFRValidatedForms.git", :tag => s.version.to_s }
  s.source_files  = "VFRValidatedForms", "VFRValidatedForms/**/*.{h,m}"
  s.requires_arc = true
end
