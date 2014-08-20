#####Scroll down for English#####

###A fő koncepció bemutatása###

Ez az alkalmazás a ruby-ban írt Sinatra keretrendszeren alapszik, azon belül is többnyire [ezen a adattáron](https://github.com/Core966/Sinatra_Template_Kickstart).

Az alkalmazás az egyszerűségre törekszik, viszont nem a könnyen érthetőség kárára. Az alkalmazás könnyen módosítható és bővíthető. Hamar át lehet látni a működését.

Viszont mielőtt megértenénk a működését bontsuk le egyenként a komponenseit:

####Alappillérek (itt kezdődik minden)####

Az alkalmazás a core.rb fájlból indul, ez tisztán látható a config.ru fájlban is ami a core.rb fájlra támaszkodik amikor elindítja az alkalmazást éles környezetben:

>	require File.join(File.dirname(__FILE__), 'core.rb')
>	run Sinatra::Application

A core.rb fájl valójában az olvastótégelye az összes többi fájlnak a programban, a core.rb fájlban található például a posts vezérlő beillesztése:

>	require File.join(File.dirname(__FILE__), './posts_controller.rb')

Valamint a fő konfigurációk:

>	configure do
>		set :views, "#{File.dirname(__FILE__)}/views"
>		enable :sessions
>		use Rack::Session::Cookie, :expire_after => 60*60*3, secret: "nothingissecretontheinternet"
>		use Rack::Csrf
>		use Rack::MethodOverride
>	end



###Introduction to main concept###



How to use:

Install dependencies (bundle)

migrate (rake db:migrate)

Run Application (ruby core.rb)

Also, make sure to check the following:

rake -T

use Ruby 2.0.0 or greater

change session cookie secret

set up database yaml file

create a new user and remove the default one

