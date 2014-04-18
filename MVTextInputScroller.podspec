Pod::Spec.new do |s|
  s.name         = "MVTextInputScroller"
  s.version      = "1.0.1"
  s.summary      = "Class to automatically center vertically any input fields within a UIScrollView hierarchy when active"

  s.description  = <<-DESC

                   DESC

  s.homepage     = "https://github.com/bizz84/MVTextInputScroller"

  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }

  s.author       = { "Andrea Bizzotto" => "bizz84@gmail.com" }

  s.platform     = :ios, '7.0'

  s.source       = { :git => "https://github.com/bizz84/MVTextInputScroller.git", :tag => '1.0.1' }

  s.source_files = 'MVTextInputsScroller/*.{h,m}'

  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'

  s.requires_arc = true

end
