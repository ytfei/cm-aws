Gem::Specification.new do |s|
  s.name = "cm-aws"
  s.version = '0.0.1'
  s.date = '2014-07-04'
  s.authors = ["Evans Yang"]
  s.email = ["ytfei01@foxmail.com"]
  s.summary = "Setup my AWS environment"
  s.description = "Install required components on AWS"
  s.homepage = "http://codingme.com"

  s.add_dependency 'aws-sdk', '~> 1.46.0'
  s.add_dependency 'net-ssh', '~> 2.9.1'

  s.files = `git ls-files`.split("\n").reject { |path| path =~ /\.gitignore$/ }
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
end
