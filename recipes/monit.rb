# Add Monit configuration file via the `monitrc` definition
#
begin
  monitrc "elasticsearch" do
    template_cookbook "elasticsearch"
    variables({:pidfile => "#{node.elasticsearch[:pid_path]}/#{node.elasticsearch[:node_name].to_s.gsub(/\W/, '_')}.pid"})
  end
rescue Exception => e
  Chef::Log.error "The 'monit' recipe is not included in the node run_list or the 'monitrc' resource is not defined"
  raise e
end
