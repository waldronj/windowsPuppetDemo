
## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'learn.localdomain',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
}

node 'WIN-RQSUS89RFK9.kc.rr.com' {
  dism{'NetFx3':
   ensure=> present,
  }->
  dism{'IIS-WebServerRole':
    ensure=> present,
  } ->
  dism { 'IIS-WebServer':
    ensure => present,
  }->
  dism{'IIS-ISAPIFilter':
    ensure=> present,
  }->
  dism{'IIS-ISAPIExtensions':
    ensure=> present,
  }->
  dism{'IIS-NetFxExtensibility':
    ensure=> present,
  }->
  dism{'IIS-ASPNET':
    ensure=> present,
  }
 $str = "if(!(test-path 'c:/users/administrator/desktop/dotNetFx40_Full_x86_x64.exe')){
    \$wc = new-object net.webclient
  \$url = 'http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe'
  \$file = 'c:\\users\\administrator\\desktop\\dotNetFx40_Full_x86_x64.exe'
  \$wc.DownloadFile(\$url, \$file)
  }
  "
  file{'c:/users/administrator/desktop/puppet.ps1':
    ensure=> present,
    content=> "$str",
  }->
  exec{'getNet4':
    command=> 'c:\\users\\administrator\\desktop\\puppet.ps1',
    provider=> powershell,
  }->
  exec{'installNet4':
    command=> 'c:\\users\\administrator\\desktop\\dotNetFx40_Full_x86_x64.exe /q /norestart',
    provider=> powershell,
  }
  file {'c:/puppet_iis_demo':
        ensure => directory,
          }

  file {'c:/puppet_iis_demo/default.aspx':
    content =>
    '<%@ Page Language="C#" %>
    <!DOCTYPE html>
    <html>
    <head>
    <title>Managed by Puppet</title>
    </head>
    <body>
    <h1>Managed by Puppet</h1>
    <strong>Time:</strong> <%= DateTime.UtcNow.ToString("s") + "Z" %>
    </body>
    </html>'
  }

  iis_apppool {'PuppetIisDemo':
    ensure                => present,
    managedpipelinemode   => 'Integrated',
    managedruntimeversion => 'v2.0',
  }

  iis_site {'PuppetIisDemo':
  ensure   => present,
  bindings => ["http/*:25999:"],
  }

  iis_app {'PuppetIisDemo/':
    ensure          => present,
    applicationpool => 'PuppetIisDemo',
  }

  iis_vdir {'PuppetIisDemo/':
    ensure       => present,
    iis_app      => 'PuppetIisDemo/',
    physicalpath => 'c:\puppet_iis_demo'
  }
}
