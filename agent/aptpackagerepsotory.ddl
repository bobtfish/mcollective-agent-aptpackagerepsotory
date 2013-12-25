metadata :name => "aptpackagerepsotory",
         :description => "Trivial apt package repository maintainance",
         :author => "Tomas Doran",
         :license => "Apache2",
         :version => "0.0.1",
         :url => "https://github.com/bobtfish/mcollective-agent-aptpackagerepsotory",
         :timeout => 60

action "add", :description => "Add a package to the repository" do
  display :always

  input :uri,
    :description => 'uri',
    :display_as => 'URI to get the new package from',
    :optional => false,
    :type => :string,
    :prompt => 'URI to get package from?',
    :maxlength => 512

  input :dist,
    :description => "distribution",
    :display_as => 'the distribution to add the package to',
    :optional => false,
    :type => :string,
    :prompt => 'Distribution (precise/squeeze?)',
    :validation => '^(precise|squeeze)$',
    :maxlength => 7

  input :arch,
    :description => "architecture",
    :display_as => "the architecture to add the package for (amd64/i386)",
    :optional => false,
    :type => :string,
    :prompt => 'Architecture (i386/amd64?)',
    :validation => '^(i386|amd64)$',
    :maxlength => 7 

  output :status,
    :description => "The command exit code",
    :display_as  => "Exit code"

end

