Pod::Spec.new do |s|
  s.name         = "HeartBLE"
  s.version      = "1.0.0"
  s.summary      = "A summary of HeartBLE."

  s.description  = <<-DESC
                   A longer description of HeartBLE in Markdown format.
                   DESC

  s.homepage     = "https://github.com/tiz52/HeartBLE"
  s.license      = "MIT"
  s.author       = { "Your Name" => "carls.mrz@gmail.com" }
  s.source       = { :git => "https://github.com/Tiz52/HeartBLE.git", :tag => "#{s.version}" }

  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.source_files = "HeartBLE/**/*.{h,m}"
  s.public_header_files = "HeartBLE/**/*.h"

  s.frameworks = "CoreBluetooth"

  s.dependency "React"
end
