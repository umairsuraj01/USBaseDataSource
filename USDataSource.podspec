Pod::Spec.new do |s|
  s.name         = "USDataSource"
  s.version      = "0.4.2"
  s.summary      = "Fantastic data sources for your UITableView and UICollectionView."
  s.homepage     = "https://github.com/umairsuraj01/USBaseDataSource"
  s.license      = { :type => 'MIT', :file => 'LICENSE'  }
  s.author       = { "Muhammad Umair Soorage" => "umairsuraj.engineer@gmail.com" }
  s.source       = { :git => "https://github.com/umairsuraj01/USBaseDataSource.git", :tag => s.version.to_s }
  s.platform     = :ios, '14.0'
  s.requires_arc = true
  s.source_files = 'USDataSource/**/*.swift'
  s.frameworks   = 'UIKit', 'CoreData'
  s.social_media_url = ""
  s.compiler_flags = "-fmodules"
  s.swift_versions = "5.0"
end
