Pod::Spec.new do |s|
  s.name         = "ListUpdater-OC"
  s.version      = "1.0.0"
  s.summary      = "Easy to perform delete/move/insert animations in UITableView or UICollectionView for iOS"
  s.homepage     = "https://github.com/NSJoe/ListUpdater"
  s.license      = "MIT"
  s.author             = { "NSJoe" => "joeadeline@icloud.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/NSJoe/ListUpdater.git", :tag => s.version }
  s.source_files  = "source/*.{swift}"
  s.framework  = "UIKit"

  s.description  = <<-DESC 
                          ListUpdater 是一个简化UITableView和UICollectionView动画执行的库，同时支持扩展
                   DESC

  s.license      = { :type => "MIT", :file => "LICENSE" }

end
