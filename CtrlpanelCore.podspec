Pod::Spec.new do |s|
  s.name         = "CtrlpanelCore"
  s.version      = %x(git describe --tags --abbrev=0).chomp
  s.summary      = "Core library to build a client that interacts with the Ctrlpanel API"
  s.description  = "This is the Ctrlpanel core library intended for building clients that interacts with the Ctrlpanel API"
  s.homepage     = "https://github.com/ctrl-alt-deseat/swift-ctrlpanel-core"
  s.license      = "Copyright"
  s.author       = { "Linus Unnebäck" => "linus@folkdatorn.se" }

  s.swift_version = "4.0"
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"

  s.source       = { :git => "https://github.com/ctrl-alt-deseat/swift-ctrlpanel-core.git", :tag => "#{s.version}" }
  s.source_files = "Sources"

  s.dependency "LinusU_JSBridge", "1.0.0-alpha.15"
  s.dependency "PromiseKit", "~> 6.0"
  s.dependency "Signals", "~> 6.0"
end
