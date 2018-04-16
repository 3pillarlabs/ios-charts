Pod::Spec.new do |s|
  s.name         = "iOSCharts"
  s.version      = "1.1.1"
  s.summary      = "A small charts framework."
  s.description  = "This framework aims to provide an easy way to visualize a set of data using “off the shelf” solutions for Line Graph, Stacked Bar Graph and Pie Chart, allowing the user to change the data source by adding or removing new values."
  s.homepage     = "https://github.com/3pillarlabs/ios-charts"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "3Pillar Global"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/3pillarlabs/ios-charts.git", :tag => "#{s.version}" }
  s.source_files = "Sources/*"
end
