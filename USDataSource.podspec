Pod::Spec.new do |s|
  s.name         = "USDataSource"
  s.version      = "0.1"
  s.summary      = "Flexible data sources for your UITableView and UICollectionView."
  s.homepage     = "https://github.com/umairsuraj01/USBaseDataSource"
  s.author       = { "Umair Suraj" => "umairsuraj.engineer@gmail.com" }
  s.source       = { :git => "https://github.com/umairsuraj01/USBaseDataSource", :tag => s.version.to_s }
  s.platform     = :ios, '12.0'
  s.requires_arc = true
  s.source_files = 'USDataSource/**/*.swift'
  s.frameworks   = 'UIKit', 'CoreData'
  s.social_media_url = ""
  s.compiler_flags = "-fmodules"
end
