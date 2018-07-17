
Pod::Spec.new do |s|

  s.name         = "MXPlaygroundHub"
  s.version      = "0.0.1"
  s.summary      = "用于快速集成ViewController的Controller"

  s.description  = <<-DESC
                   用于快速集成ViewController的Controller, 一般这些controller用作playground
                   DESC

  s.homepage     = "https://github.com/max2oi"
  s.license      = "LICENSE"
  s.author             = { "max2oi" => "max2oi.xiao@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/max2oi/MXPlaygroundHub/tree/master.git", :tag => "#{s.version}" }
  s.source_files  = "MXPlaygroundHub"

end
