Pod::Spec.new do |s|
    s.name = 'MacBond'
    s.version = '1.0.0'
    s.license = 'MIT'
    s.platform = :osx, '10.10'
    s.summary = 'An OS X port of the Bond binding framework'
    s.homepage = 'https://github.com/wjk/MacBond'
    s.authors = { 'William Kent' => 'wjk011@gmail.com' }
    s.source = { :git => 'https://github.com/wjk/MacBond.git', :tag => s.version.to_s }
    s.source_files = 'MacBond/*.swift'
    s.requires_arc = true
end
