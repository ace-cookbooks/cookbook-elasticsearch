[Chef::Recipe, Chef::Resource].each { |l| l.send :include, ::Extensions }

# Install the Fog gem dependencies
#
value_for_platform_family(
  [:ubuntu, :debian]               => %w| build-essential libxslt1-dev libxml2-dev |,
  [:rhel, :centos, :suse, :amazon] => %w| gcc gcc-c++ make libxslt-devel libxml2-devel |
).each do |pkg|
  package(pkg) { action :nothing }.run_action(:upgrade)
end

# Install the Fog gem for Chef run
#
require 'rubygems/specification'

chef_gem("excon") do
  version '0.25.3'
end
chef_gem("formatador") do
  version '0.2.4'
end
chef_gem("net-scp") do
  version '1.1.2'
end

gem_path = Gem.path.first
$LOAD_PATH << "#{gem_path}/gems/excon-0.25.3/lib"
$LOAD_PATH << "#{gem_path}/gems/formatador-0.2.4/lib"
$LOAD_PATH << "#{gem_path}/gems/net-scp-1.1.2/lib"

Gem::Specification._all['excon'] = Gem::Specification.load("#{gem_path}/specifications/excon-0.25.3.gemspec")
Gem::Specification._all['formatador'] = Gem::Specification.load("#{gem_path}/specifications/formatador-0.2.4.gemspec")
Gem::Specification._all['net-scp'] = Gem::Specification.load("#{gem_path}/specifications/net-scp-1.1.2.gemspec")
chef_gem("fog") do
  version '1.14.0'
  action :install
end
$LOAD_PATH << "#{gem_path}/gems/fog-1.14.0/lib"
Gem::Specification._all['fog'] = Gem::Specification.load("#{gem_path}/specifications/fog-1.14.0.gemspec")

# Create EBS for each device with proper configuration
#
# See the `attributes/data` file for instructions.
#
node.elasticsearch[:data][:devices].each do |device, params|
  if params[:ebs] && !params[:ebs].keys.empty?
    create_ebs device, params
  end
end
