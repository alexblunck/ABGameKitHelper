Pod::Spec.new do |s|
  s.name         = "ABGameKitHelper"
  s.version      = "0.1"
  s.summary      = "Objective-C Helper class to ease interaction with Apples GameKit API"
  s.homepage     = "https://github.com/ablfx/ABGameKitHelper"
  s.license      = { :type => "MIT", :file => "LICENSE"}
  s.author       = { "Alexander Blunck" => "alex@ablfx.com" }
  s.source       = { :git => "https://github.com/ablfx/ABGameKitHelper.git", :tag => "0.1" }

  s.source_files = 'Classes', 'ABGameKitHelper/*.{h,m}'
  s.requires_arc = true
  s.frameworks = 'SystemConfiguration'
end
