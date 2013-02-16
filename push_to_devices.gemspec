Gem::Specification.new do |gem|
    gem.name        = %q{push_to_devices}
    gem.version = "0.0.6"
    gem.date = %q{2013-02-15}
    gem.authors     = ["Lloyd Meta"]
    gem.email       = ["lloydmeta@gmail.com"]
    gem.homepage    = "http://github.com/lloydmeta/push_to_devices_rb"
    gem.description = %q{A Ruby library for interfacing with push_to_devices}
    gem.summary     = gem.description

    gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
    gem.files         = `git ls-files`.split("\n")
    gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    gem.require_paths = ["lib"]

    gem.add_dependency 'json'

    gem.add_development_dependency 'rake'
    gem.add_development_dependency 'rspec'
    gem.add_development_dependency 'webmock'
    gem.add_development_dependency 'active_support'
    gem.add_development_dependency 'i18n'

end