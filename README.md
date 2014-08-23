#####Scroll down for English#####

###A fő koncepció bemutatása###

Ez az alkalmazás a ruby-ban írt Sinatra keretrendszeren alapszik, azon belül is többnyire [ezen a adattáron](https://github.com/Core966/Sinatra_Template_Kickstart).

Az alkalmazás az egyszerűségre törekszik, viszont nem a könnyen érthetőség kárára. Az alkalmazás könnyen módosítható és bővíthető. Hamar át lehet látni a működését.

Viszont mielőtt megértenénk a működését bontsuk le egyenként a komponenseit:

####Alappillérek####

Az alkalmazás a core.rb fájlból indul, ez tisztán látható a config.ru fájlban is ami a core.rb fájlra támaszkodik amikor elindítja az alkalmazást éles környezetben:

>	require File.join(File.dirname(__FILE__), 'core.rb')<br/>
>	run Sinatra::Application

A core.rb fájl valójában az olvasztótégelye az összes többi fájlnak a programban, a core.rb fájlban található például a posts vezérlő beillesztése:

>	require File.join(File.dirname(__FILE__), './posts_controller.rb')

Valamint a fő konfigurációk:

>	configure do<br/>
>		set :views, "#{File.dirname(__FILE__)}/views"<br/>
>		enable :sessions<br/>
>		use Rack::Session::Cookie, :expire_after => 60*60*3, secret: "nothingissecretontheinternet"<br/>
>		use Rack::Csrf<br/>
>		use Rack::MethodOverride<br/>
>	end

De nézzük át egyesével a program egyes komponenseit. Az elejétől a végéig nézzük hogy hogyan áll össze ez az alkalmazás a core.rb-ből kiindulva:

#####Az első lépések (az adatbázis kapcsolata)#####

Az alkalmazás, ha nem közvetlenül van futtatva a 'ruby core.rb' paranccsal, akkor a config.ru fájlból fog kiindulni. Ez éles környezetben van használva.

Egyébként meg a webrick teszt webszerver fogja kiszolgálni a localhost 4567-es számú portján.

Először, a működéshez elengedhetetlen gem fájlokat fogja betölteni. Ezeknek a működése mind megtekinthetőek az interneten.

Röviden részletezve:

>require 'bundler/setup'

A bundler/setup arra szükséges hogy 'bundle install' paranccsal az összes gem-et tudjuk telepíteni ami szükséges a program működéséhez, tehát ilyenkor a 'Gemfile' fájlban meg fogja keresni a telepítendő összetevőket, majd a Gemfile.lock-al véglegesíti azt.

>require 'sinatra'

Ez a fő keretrendszere az alkalmazásnak. Ez alapvetően ahhoz kell hogy a ruby kódot, ami nem web alapú mint például a php, tudjuk használni webes alkalmazások létrehozásához.

>require 'active_record'

Ez az egyik legnépszerűbb ORM-je a ruby-nak. Avagy Object Relational Mapper. Ez felel azért hogy a programunk könnyebben el tudja érni az adatbázist.

>require 'yaml'

Erre azért van szükségünk hogy könnyebben tudjuk konfigurálni a szükséges paramétereket az adatbázisunk működéséhez.

>require 'warden'

A fenti gem teszi lehetővé hogy bármilyen külső harmadik féltől származó szoftver nélkül (pl. facebook-on meg twitteren való bejelentkezés nélkül) a saját adatbázisunkat használjuk a felhasználók biztonságos kezeléséhez. Ehhez még hozzájárul az alábbi gem is:

>require 'bcrypt'

Ez szükséges ahhoz hogy az OpenBSD bcrypt titkosítását tudd használni az alkalmazásodhoz.

>require 'rack/csrf'

Ez a "cross site request forgery" elleni támadások ellen van. Avagy "oldalon-keresztüli kéréshamisítás". Minden felküldött adat esetében a 'Rack::Csrf.csrf_tag(env)' értékkel lehet csak érvényesen elküldeni az adatokat. Ezt az értéket csak az alkalmazás ismeri, így lehetetlen egy másik oldalról hamis adatot küldeni. Részletek [itt](http://hu.wikipedia.org/wiki/Cross-site_request_forgery).

Miután a függőségek betöltésre kerülnek a program a legfontosabb dolog betöltésével kezdi, ez az adatbázisnak a modell adatai:

>$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/models") <br/>
>Dir.glob("#{File.dirname(__FILE__)}/models/*.rb") { |model| require File.basename(model, '.*') }

Az összes adatot be fogja tölteni a models mappából.

De nézzük meg hogy pontosan milyen adatokat fog betölteni (egy példát nézünk):

>class Feed < ActiveRecord::Base <br/>
>validates :title, format: { with: /\A[\s\p{L}0-9 \.,!?]{1,}\z/ } <br/>
>validates :content, format: { with: /\A[\s\p{L}0-9 \.,!?]{1,}\Z/ } <br/>
>validates :is_deleted, format: { with: /\Atrue\z/ }, on: :update <br/>
>end

Először a Feed osztály ami a hír bejegyzéseknek az adattábláját képviseli, megörökli a ActiveRecord ORM attribútumait. Ez lehetővé teszi hogy az adatbázisba került értékeket érvényesítsük mielőtt rögzítésre kerülnek. A lenti példákkal ezt mind reguláris kifejezésekkel tesszük lehetővé. (Ha te is kísérletezni szeretnél reguláris kifejezésekkel, látogasd meg [ezt az oldalt](http://rubular.com/).)

Ellenőrizzük hogy a cím minimum egy karakterből álljon és hogy lehetnek benne ékezetes és sima betűk, valamint számok. Továbbá lehet benne pont, vessző, felkiáltójel és kérdőjel. A cím nem lehet több soros, miközben a hír bejegyzés tartalma ezt lehetővé teszi.

Továbbá az adatbázisból csak törölni lehet, ezt is itt ellenőrizzük le. Hogy ez miért jelenti azt hogy csak true értéket adhatunk át az adatbázisba az is_deleted mezőbe arról később bővebben fogunk beszélni.

A többi fájl ugyanígy tartalmazza az adatok érvényesítését a blog bejegyzések, felhasználók, linkek esetében is.

Viszont ez önmagában nem lenne elég ahhoz hogy az adatbázissal kommunikáljon az alkalmazás, ehhez a rake db:migrate parancs is nélkülözhetetlen, ez a parancs viszont egy nagyon fontos fájlon alapszik ami a core.rb következő része:

>APP_CONFIG = YAML.load_file('./config/database.yml') <br/>
>ActiveRecord::Base.establish_connection( <br/>
>encoding: APP_CONFIG['db_encoding'], <br/>
>adapter: APP_CONFIG['db_adapter'], <br/>
>host: APP_CONFIG['db_host'], <br/>
>database: APP_CONFIG['db_name'], <br/>
>username: APP_CONFIG['db_username'], <br/>
>password: APP_CONFIG['db_password'] <br/>
>)

Az első sor a config mappában a database.yml fájlban keresi. Figyelembe kell venni hogy ez az adattárban nem található, ez azért van mert az a mappa a .gitignore fájlhoz hozzá van adva. A használat előtt ezt a fájlt manuálisan kell létrehozni ilyen formában:

>Necessary format: <br/>
>db_encoding: `<db encoding here>` <br/>
>db_adapter: `<db adapter here>` <br/>
>db_name: `<db name here>` <br/>
>db_host: `<hostname here>` <br/>
>db_username: `<db username here>` <br/>
>db_password: `<db user password here>`

Tehát a megoldás így nézne ki:

>db_encoding: utf8 <br/>
>db_adapter: mysql2 <br/>
>db_name: test <br/>
>db_host: localhost <br/>
>db_username: test_user <br/>
>db_password: test123

Különösen kell figyelni a space-ekre, mert a yaml azokat is figyelembe veszi. Ha például két space van a 'db_name:' és a 'test' között akkor már nem fog helyesen betöltődni a konfiguráció!

Így már elég adatunk van hogy elindítsuk az adattáblák létrehozását. Tehát létre kell hozni a 'test' adatbázist és a 'test_user' felhasználót, valamint hozzáférést kell az adatbázishoz biztosítani a 'test_user' felhasználónak a 'test' adatbázishoz.

Szintén figyelembe kell venni, hogy az utf8 karakterkódolást adatbázis oldalról is biztosítani kell, valamint hogy az alkalmazás is ismerje a karakterkódolást a mysql2 és nem a mysql adaptert kell használni, továbbá ruby 2.0-át kell használni legalább. Ha ez a 4 (utf8 kódolás active record szinten, utf8 kódolás adatbázis szinten, mysql2 adapter használata valamint legalább ruby 2.0 használata) nem jön össze, akkor az alkalmazás nem fog működni magyar karakterekkel vagy bármilyen más karakterrel amit az utf8 támogat és az ASCII karaktertábla nem.

Ha az alapfeltételek teljesülnek, akkor elméletileg elindíthatjuk a rake db:migrate paranccsal az adattáblák létrehozását. De honnan tudja az alkalmazás hogy hogyan hozza létre az adattáblákat?

A válasz a db mappában van. Azon belül is a migrate mappában, viszont már a db mappában lévő schema.rb fájlban is tisztán láthatjuk hogyan vannak összeállítva az adattáblák:

>ActiveRecord::Schema.define(version: 20140716190802) do <br/>
>create_table "feeds", force: true do |t| <br/>
>t.string "title" <br/>
>t.text "content" <br/>
>t.boolean "is_deleted" <br/>
>t.datetime "created_at" <br/>
>t.datetime "updated_at" <br/>
>end <br/>
>create_table "links", force: true do |t| <br/>
>t.string "title" <br/>
>t.string "href" <br/>
>t.datetime "created_at" <br/>
>t.datetime "updated_at" <br/>
>end <br/>
>create_table "posts", force: true do |t| <br/>
>t.string "title" <br/>
>t.text "body" <br/>
>t.boolean "is_deleted" <br/>
>t.datetime "created_at" <br/>
>t.datetime "updated_at" <br/>
>end <br/>
>create_table "users", force: true do |t| <br/>
>t.string "username" <br/>
>t.string "email" <br/>
>t.string "password_hash" <br/>
>t.string "password_salt" <br/>
>t.boolean "is_deleted" <br/>
>t.datetime "created_at" <br/>
>t.datetime "updated_at" <br/>
>end <br/>
>end

Ha viszont azt szeretnénk látni hogy mit csinál pontosan a rake db:migrate parancs, akkor a migrate mappában nézzük azt meg.

Vegyük példának a '20140524192849_create_posts.rb' fájlt:

>class CreatePosts < ActiveRecord::Migration <br/>
>def up <br/>
>create_table :posts do |t| <br/>
>t.string :title <br/>
>t.text :body <br/>
>t.boolean :is_deleted <br/>
>t.timestamps <br/>
>end <br/>
>Post.create(title: "My first post", body: "Quisque lobortis, velit ut aliquet interdum, tellus mauris ornare nunc, et dapibus tortor odio quis metus. Aenean sed velit vitae lorem dignissim fermentum. Praesent sit amet neque vehicula, pharetra sapien et, egestas quam. Suspendisse aliquet, massa a posuere scelerisque, velit orci hendrerit magna, ac elementum odio arcu quis ligula. Morbi lacus magna, tempus id enim vitae, imperdiet tempor nulla. Morbi sodales orci sapien, vitae hendrerit dolor hendrerit in. Praesent accumsan neque vel dui pretium iaculis. Suspendisse potenti. Phasellus interdum ut ligula vel fringilla. Praesent suscipit diam at fringilla molestie. Integer ut porta lectus. Sed rhoncus in massa quis dignissim. Curabitur orci arcu, egestas vel sem a, mollis aliquam risus. Nullam orci risus, viverra id aliquet vitae, adipiscing eget nulla. Suspendisse elementum facilisis elit eu commodo. Donec sollicitudin, ligula eget tempus luctus, metus urna sollicitudin tortor, ut iaculis erat sapien ac nisi.", is_deleted: false) <br/>
>Post.create(title: "My second post", body: "Duis tempor gravida enim, ut tempor arcu pretium aliquam. Pellentesque varius, mauris in accumsan sagittis, lacus nisl malesuada mi, ac placerat elit ipsum nec tortor. Ut eu metus nec justo interdum placerat quis id justo. Nullam sem nisi, rhoncus eget lectus non, auctor dictum dui. Nam bibendum diam facilisis semper placerat. Quisque eget tortor quis leo tempor eleifend quis nec dui. Nunc bibendum dapibus nibh vitae auctor. Pellentesque tempus pharetra purus a pharetra. Suspendisse libero urna, auctor ac eleifend ac, tincidunt eget risus. Proin congue enim sit amet augue vestibulum ornare in at ligula. Curabitur faucibus ullamcorper massa, a adipiscing turpis condimentum eget. Duis commodo diam sed volutpat porta. Maecenas placerat orci est, at tempor augue accumsan eleifend. Proin pellentesque posuere faucibus.", is_deleted: false) <br/>
>Post.create(title: "My third post", body: "Integer et viverra augue. Nullam nisi velit, pretium id fermentum vel, venenatis nec erat. Nam suscipit, diam vel cursus condimentum, turpis sem euismod metus, congue congue massa ipsum in odio. Etiam in tristique sapien. Cras eu auctor neque, sed consectetur libero. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nullam venenatis consequat leo, a vehicula neque laoreet at. Ut lobortis in lectus eget convallis. Pellentesque non gravida sem. Aenean faucibus massa lorem, et hendrerit elit vestibulum et. Donec ut ultricies diam. Curabitur sit amet ligula nec elit condimentum fringilla quis non tortor. Proin accumsan porttitor nisl ut congue. Donec ac enim augue. Aliquam at odio sit amet nisl pharetra mollis nec placerat leo. Duis tempor quam augue, vitae ultrices felis tristique nec.", is_deleted: false) <br/>
>end <br/>
>def down <br/>
>drop_table :posts <br/>
>end <br/>
>end

Amit a fenti hoz létre az a blog bejegyzések adattáblája három minta bejegyzéssel.

Létrehozza a posts adattáblát, string típusú címmel, text típusú tartalommal, add hozzá egy törölve igaz/hamis értéket (ami értelemszerűen létrehozáskor mindig hamis), valamint az időbélyegeket hozzá. Mikor lett létrehozva és módosítva.

Ezután létrehozza a minta bejegyzéseket végül meghatározza hogy mit tegyen hogyha vissza szeretnénk forgatni a létrehozását. Ilyenkor egyszerűen törli az adattáblát.

A rake db:migrate parancs során az összes adattáblát létrehozza, a rake db:rollback során pedig egy adattáblát eldob, persze megadhatjuk neki hogy ugorjon vissza több lépéssel így visszaforgathatjuk egy paranccsal, teljesen, az adatbázisok létrehozását.

Viszont ezeket a rake parancsokat hogyan értelmezi az alkalmazásunk? Minden válaszunk megtalálható a Rakefile-ban:

>require "./active-record/rake.rb" <br/>
>require "./core.rb"

Persze ez erős túlzás, amire mi vagyunk kíváncsiak az az active-record mappában található rake.rb fájl.

A kód, és minden kód ami az active-record mappában található az egy másik adattárból származik, ami szintén az MIT licenc alatt készült. Kompatibilitási problémák merültek fel mysql adatbázis használat során és ezért közvetlenül az alkalmazásba kellet integrálnom azokat a részeket amikre szükségem volt. Alapvetően ez a fájl végzi a közvetlen kommunikációt az Active Record ORM-el. Jobban kivehető, hogy a tasks.rake fájlban lévő parancsokat lefordítja az ORM-nek. Amíg a tasks.rake például a 'rake -T' paranccsal röviden leírja a különféle parancsok működését, addig a rake.rb fájl az olyan komplex dolgokat végzi el, mint például hogy milyen formában legyen létrehozva egy új migrációs fájl, amikor az alkalmazás még tervezési fázisban van.

Az utóbbiról egy részlet:

>migration_number = version || Time.now.utc.strftime("%Y%m%d%H%M%S") <br/>
>migration_file = File.join(migrations_dir, "#{migration_number}_#{migration_name}.rb")

(Megjegyzés: a 'migration_name' változót azt a programozó adja meg amikor a 'rake db:create_migration' parancsot használja.)

Ezzel gyorsan át is tekintettük az adatbázis és az alkalmazás közti kapcsolatot. Viszont most jön az a szerver oldali kód ami lehetővé teszi hogy a felhasználók és az oldal látogatói számára is elérhetőek legyenek az adatok.

#####Az alkalmazás fő elemeinek áttekintése#####

Először a Sinatra alkalmazást beállítjuk, ezt a configure blokk-ban tehetjük ami így néz ki:

>configure do <br/>
>set :views, "#{File.dirname(__FILE__)}/views" <br/>
>enable :sessions <br/>
>use Rack::Session::Cookie, :expire_after => 60*60*3, secret: "nothingissecretontheinternet" <br/>
>use Rack::Csrf <br/>
>use Rack::MethodOverride <br/>
>end

Először beállítjuk hogy milyen mappában keresse a view fájlokat, ezek a fájlok amik az oldal látogatói és használói számára kerülnek megjelenítésre. (A Model View Controller avagy MVC megnevezés alapján ez a neve.)

Következő lépés az az, hogy engedélyezzük a session-öket, tehát a munkameneteket engedéllyezük, ez ahhoz szükséges hogy az éppen bejelentkezett felhasználó adait az alkalmazás meg tudja jegyezni az oldalak közötti lépkedés közben.

Utána beállítjuk a sütiket, ezek a fájlok a böngésző által kerülnek tárolásra és az éppen bejelentkezett felhasználó adatait tárolja. Beállításra kerül hogy mikor járjon le, valamint hogy milyen jelszóval titkosítjuk.

Utána beállítjuk a csrf védelmet.

A 'use Rack::MethodOverride' arra szolgál, hogy tudjunk használni put és delete metódusokat az alkalmazáson belül, ne csak GET és POST metódusokat amik alapértelmezetten vannak támogatva.

Ezután következik a 'warden_auth.rb' fájl hozzáadása az alkalmazáshoz. Ez a fájl áll közvetlen kapcsolatban a Warden gem-el. (A Warden az a Devise-nak volt az elődje, mivel a Devise Rails orientált ezért a Sinatra alkalmazásokhoz továbbra is a warden-t kell használni.)

A Warden-nek is van egy saját konfigurációs blokkja amit így kell beállítani:

>use Warden::Manager do |config| <br/>
>config.serialize_into_session{|user| user.id } <br/>
>config.serialize_from_session{|id| User.find_by_id(id) } <br/>
>config.scope_defaults :default, <br/>
>strategies: [:password] <br/>
>config.failure_app = self <br/>
>end

Először megadjuk hogy hogyan tárolja a sütikben a felhasználó adatait, majd hogy hogyan olvassa ki az adatokat onnan.

A strategies egy fontos érték amit később deklarálunk, az határozza meg hogy milyen logika alapján hitelesítse a felhasználókat.

Valamint az utolsó sor pedig azt határozza meg hogy mit tegyen az alkalmazás ha hibára fut a bejelentkezés. Itt nem adunk meg speciális hiba kezelő mechanizmust, főként azért mert már bejelentkezéskor leellenőrzi az alkalmazás hogy a felhasználó be van-e jelentkezve, és ha nem, akkor egyszerűen visszadobja a főoldalra.

Az első amit meghatározunk az az, hogy POST metódusban várja a felhasználó által megadott értékeket:

>Warden::Manager.before_failure do |env,opts| <br/>
>env['REQUEST_METHOD'] = 'POST' <br/>
>end

Utána jön a lényeg:

>Warden::Strategies.add(:password) do <br/>
>def valid? <br/>
>params['user'] && params['user']['email'] && params['user']['password'] <br/>
>end <br/>
>def authenticate! <br/>
>user = User.find_by(email: params['user']['email']) <br/>
>if user.nil? <br/>
>fail!("The username you entered does not exist.") <br/>
>elsif user.authenticate(params['user']['email'], params['user']['password']) && user.is_deleted == false <br/>
>success!(user) <br/>
>else <br/>
>fail!("Could not log in") <br/>
>end <br/>
>end <br/>
>end

Először azt vizsgáljuk meg hogy a felhasználó megadott-e email címet és jelszót. Ha ezek az adatok megérkeztek a szerverre akkor folytatja.

Elővesszük először email cím alapján hogy melyik felhasználóról van pontosan szó.

Viszont ha nem találjuk meg email cím alapján akkor eleve nem kell hitelesíteni a felhasználót és hibára fut a bejelentkezés.

Viszont ha van akkor megnézzük hogy a jelszó egyezik-e. Ez active record szinten történik, ugyanis amikor felkerestük a felhasználót az email címe alapján, akkor a hozzá tartozó metódust is eltároltuk a user objektumban ami így néz ki:

>def authenticate(email, password) <br/>
>user = User.find_by(email: email) <br/>
>if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt) <br/>
>user <br/>
>else <br/>
>nil <br/>
>end <br/>
>end

És itt nem mást használunk mint a bcrypt metódusát amivel ellenőrizzük hogy az eltárolt titkosított érték, megegyezik-e a felhasználó által beírt jelszó titkosított értékével. Ha a kettő egyezik, akkor hitelesített a bejelentkezés.

Mivel nem 'nil' értékkel tér vissza, ezért az alábbi kód igaz értékkel tér vissza:

>user.authenticate(params['user']['email'], params['user']['password']) && user.is_deleted == false

Viszont ehhez arra is szükség van hogy a felhasználó ne legyen törölt állapotban.

Ezután beállítjuk azokat a változókat amik alapvetően minden oldalon beállításra kerülnek, pontosabban minden oldal lekérdezése során:

>before do <br/>
>@title = 'Tóth Mónika weboldala' <br/>
>@author = 'Tóth Mónika' <br/>
>end

A többi adat a core.rb fájlban mind a vezérlőkre irányul, valamint hogy milyen módon hívják le az adatokat az adatbázisból.

#####Az alkalmazás vezérlőinek áttekintése#####

A vezérlő alapvetően az a réteg az MVC szerkezetben ami kapcsolatot teremt a modell és a megjelenítésre kerülő oldalak között. Rajtuk keresztül áramolnak az adatok az egyik pontból a másikba.

A lenti kép magyarázza el a legjobban ennek a folyamatát:

![The MVC pattern](http://upload.wikimedia.org/wikipedia/commons/a/a0/MVC-Process.svg)

Nézzük meg az egyik vezérlőnek a működését, mondjuk azt ami a fő oldalt kezeli, onnan tudjuk ezt hogy az útvonal '/'-ra van állítva:

>get '/' do <br/>
>@posts = Post.find_by_sql("SELECT id, title, CONCAT(SUBSTRING(body,1, 250), '...') AS partial_body FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 5") #We are only displaying the first 250 characters of a given post. <br/>
>@sidebar_posts = Post.find_by_sql("SELECT id, title FROM posts WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3") <br/>
>@sidebar_links = Link.find_by_sql("SELECT title, href FROM links WHERE href <> ''") <br/>
>@sidebar_feeds = Feed.find_by_sql("SELECT id, title FROM feeds WHERE is_deleted = 0 ORDER BY id DESC LIMIT 0, 3") <br/>
>erb :home <br/>
>end

Először megkeressük az első öt legújabb blog bejegyzést, csökkenő sorrendbe jelenítjük meg az ID alapján ami által a legújabbak kerülnek felülre, ellenőrizzük azt is hogy ne legyen törölve, valamint a szövegnek csak az első 250 karakterét jelenítjük meg és a végéhez hozzáteszünk három pontot.

Láthatjuk azt is hogy a linkeken kívül (amik előre bejegyzésre kerülnek az adatbázisba és amúgy sem törölhetőek), minden adattábla esetében leellenőrizzük, hogy törölt-e. Ha megfigyeljük például a blog bejegyzések vezérlőjét akkor lehet látni hogy a delete metódust soha nem használjuk, csak a put-ot:

>put '/blog/:id' do <br/>
>if env['warden'].authenticate <br/>
>post = Post.find(params[:id]) <br/>
>if post.update_attributes(params[:post]) <br/>
>redirect "/blog" <br/>
>else <br/>
>redirect to("/blog/#{params[:id]}") <br/>
>end <br/>
>else <br/>
>redirect '/login' <br/>
>end <br/>
>end

Valamint a blog bejegyzéseket nem lehet szerkeszteni csak "törölni"? Ez miért van?

A probléma az adatok törlésével és a roncsolásos frissítésekkel vagy angolul: "destructive updates"-el van.

Tételezzük fel azt, hogy van egy látogató az oldalunkon aki nem csak egyszerűen egy hekker, hanem egy nagyon jó hekker. Egy olyan kis oldal esetében mint ez, magától értetődő hogy gond lesz belőle, de hogyan tudjuk csökkenteni azt hogy mekkora károkat tudjon okozni?

Azt is megtehetjük hogy a weboldal szerverén folyamatosan, mondjuk minden éjszaka csinálunk egy biztonsági mentést, viszont akkor is kiesnek azok a bejegyzések amik nap közben készültek. Nem lehet azt megoldani hogy minden bejegyzés után legyen egy biztonsági mentésünk, ez nagy oldalak esetében lehetetlen.

Ezért azt is tehetjük hogy az összes felhasználóra úgy tekintünk mint egy potenciális hekkerre, és így még saját akaratukból, vagy akár véletlenül sem tudnak törölni semmit az oldalról. Véletlenül ki lett törölve egy bejegyzés? Semmi gond: Feljelentkezem a szerverre és átállítom manuálisan az is_delete boolean értéket hamisra. Így megspórolva magamnak egy hosszabb folyamatot.

A frissítést sem szabad megengedni a felhasználóknak. Esetleg megadhatnánk a lehetőségét, hogy hozzáadjanak információt a meglévő bejegyzésekhez, de soha nem engednénk hogy frissítsék a meglévő adatot! Ugyanis ebben az esetben is, mondjuk le tudnának cserélni egy bejegyzést "lorem ipsum" szövegre, és ez adavesztést eredményezhet, amit szintén biztonsági mentés útján lehet csak helyrehozni.

Így adatvesztés csak nagyon szélsőséges esetben lehetséges.

Az alkalmazás az SQL befecskendezések ellen is védve van, ezt egyszerűen meg lehet oldani reguláris kifejezések használatával, valamint ahogyan a search mezőben lehet látni, azzal hogy a következőképpen adunk meg felhasználó által megadott értékeket az SQL lekérdezésben:

>@posts = Post.find_by_sql(["SELECT id, title, body FROM posts WHERE (title LIKE ? OR body LIKE ?) AND is_deleted = 0", "%" + params[:search][:keyword] + "%", "%" + params[:search][:keyword] + "%"])

A zárójelen belül kapcsos zárójeleket használunk, majd sorrendben behelyettesítjük a ?-ek helyére a felhasználó által megadott értékeket. Mivel a címben és tartalomban bárhol kereshetjük a keresendő értékeket, ezért az értékek elejére és végére is százalék jeleket teszünk.

A reguláris kifejezés is kiszűri a speciális karaktereket, viszont ha később lenne rá igény hogy speciális karakterekre is rá tudjanak keresni az oldal látogatói, akkor elhagyható és a beérkező karakterek más úton lennének tisztítva úgy hogy ne lehessen saját parancsokat megadni az alkalmazáson keresztül.

Lehet látni hogy a vezérlők csoportokba vannak rendezve. Ami kifejezetten az egyik adattábla vezérlője az egy külön .rb fájlban található. ezeket mind hozzáadjuk a core.rb fájlhoz az alján lévő utasításokkal:


>require File.join(File.dirname(__FILE__), './posts_controller.rb') <br/>
>require File.join(File.dirname(__FILE__), './users_controller.rb') <br/>
>require File.join(File.dirname(__FILE__), './feeds_controller.rb') <br/>
>require File.join(File.dirname(__FILE__), './links_controller.rb')

Lehet látni hogy bizonyos vezérlők védve vannak a warden gem által. Ahogy láthatjuk a blog befegyzés létrehozása a bejelentkezett felhasználó privilégiuma:

>post '/feed/?' do <br/>
>if env['warden'].authenticate <br/>
>@feed = Feed.new(params[:feed]) <br/>
>if @feed.save #In case of failure to save into the database... <br/>
>redirect "/feed/#{@feed.id}" <br/>
>else <br/>
>redirect "/feed/new" #...the application redirects to the same page. <br/>
>end <br/>
>else <br/>
>redirect '/login' <br/>
>end <br/>
>end

Mindig azt ellenőrizzük hogy az "env['warden'].authenticate" igaz értékkel tér-e vissza. Csak akkor igaz, hogyha be vagyunk jelentkezve.

Máskülönben finoman visszairányít az alkalmazás a bejelentkező felülethez.

A többi vezérlő hasonlóképpen működik, csak kisebb eltérések vannak az SQL lekérdezésekben.

#####Az alkalmazás megjelenítése#####

Az utolsó lépés, miután eltároltuk változókba a szükséges adatokat, hogy megjelenítsük őket.

A legelső dolog ami számításba fog kerülni az oldal layout eleme lesz. Ez a template-je az összes oldalnak mivel ez fogja körbefogni az összes egyedi oldalt.

A HTML kódon kívül máris láthatjuk hogy az első változót felhasználtuk:

>`<title><%= @title %></title>`

Mivel ez minden oldalon megjelenítésre kerül, ezért deklaráljuk a 'before' blokkban.

Közvetlenül utána betöltjük az összes kliens oldali kódot, ide beletartoznak a CSS stílus elemek, részük a pure.css keretrendszerből vannak.

Utána pedig a HTML5-ös bővítések, hogy már kliens oldalon érvényesítve legyenek a bevitt értékek.

A menü részben már láthatjuk hogy a warden gemmel manipuláljuk hogy mi kerüljön megjelenítésre a menüből amikor nem vagyunk bejelentkezve és amikor be vagyunk jelentkezve:

><% if env['warden'].authenticated? %> <br/>
>`<li>` <br/>
>`<a href="/users">felhasználók kezelése</a>` <br/>
>`</li>` <br/>
>`<li>` <br/>
>`<a href="/logout">Kijelentkezés</a>` <br/>
>`</li>` <br/>
><% else %> <br/>
>`<li>` <br/>
>`<a href="/login">Bejelentkezés</a>` <br/>
>`</li>` <br/>
><% end %> <br/>
>`</ul>`

Nem sokkal később megadjuk hogy mely rész fog különbözni az oldalon:

><%= yield %>

Továbbá az oldalsó sávban több értéket megjelenítünk hogy a látogatók akár egy kattintással is meg tudják nézni a legújabb vagy legfontosabb bejegyzéseket, ebből egy példa:

>`<li>` <br/>
>`<h2>Linkek</h2>` <br/>
>`<ul style="margin-bottom:15px;">` <br/>
><% @sidebar_links.each do |link| %> <br/>
>`<li>` <br/>
>`<a href="<%= link.href %>"><%= link.title %></a>` <br/>
>`</li>` <br/>
><% end %> <br/>
>`</ul>` <br/>
>`</li>`

Végül a láblécben megjelenítjük a szükséges információt, az aktuális évet kiírva:

>`<%= "&mdash; &copy; #{Time.now.strftime('%Y')} #{@author} &mdash; Weboldala, az alkalmazás <a href='https://github.com/Core966/monica_site_simple/blob/master/LICENSE'>MIT licenc</a> alatt készült. A Kód forrását meg lehet tekinteni a <a href='https://github.com/Core966/monica_site_simple'>github oldalán</a>.<br/>A gyerekrajzokat készítette: <a href='http://www.freeimages.com/profile/cieleke'>Cieleke</a>" %>`

Külön kitérve a kereső mezőre láthatjuk hogy egyrész beállítottunk egy helykitöltő szöveget, másfelől pedig regulár kifejezést és egy egyéni szöveget hibás bevitel esetében.

>`<input name="search[keyword]" placeholder="Keresendő szöveg" pattern="[\u00c0-\u00ffA-Za-z0-9]{4,}" data-errormessage-pattern-mismatch="A keresendő szövegnek minimum 4 karakterből kell állnia, lehet benne betű (ékezettel is) és szám." type="text" />`

Itt a regulár kifejezés a rendhagyó, láthatjuk hogy a p{L} használata helyett a '\u00c0-\u00ff' tartományt adjuk meg. Erre azért van szükség mert a speciális, nem ASCII karaktertáblába tartozó betűket, mint a magyar ékezetes betűket nem szabályozzák szokványos módon a Javascriptben található reguláris kifejezések, helyette viszont deklarálhatjuk hexadecimálisan milyen karaktereket nézzen a reguláris kifejezés. Minden speciális magyar és egyéb külföldi karakter beleesik a megadott tartományba. Részletes listát [ezen az oldalon](http://www.utf8-chartable.de/unicode-utf8-table.pl?utf8=dec) lehet találni.

Lássuk viszont példaként hogy mi van az főoldal esetében megadva:

><% @posts.each do |post| %> <br/>
>`<div class="entrytext">` <br/>
>`<h2><a href="/blog/<%= post.id %>"><%= post.title %></a></h2>` <br/>
>`<p><%= post.partial_body %></p>` <br/>
>`</div>` <br/>
><% end %>

Lehet látni fog végiglépkedünk az összes találaton, nem szükséges korlátozni a találatok számát mivel a lekérdezés maximum 5 találatot hoz fel, az 5 legfrissebb bejegyzést.

Vannak olyan oldalak ahol hasonlóképpen elrejtünk egyes részeket ha nincs bejelentkezve a felhasználó:

><% if env['warden'].authenticated? %> <br/>
>`<br />` <br/>
>`<br />` <br/>
>`<a class="pure-button pure-button-primary" href="/links">Mutasd az összes linket</a>` <br/>
><% end %> <br/>
>`<br />` <br/>
>`<br />` <br/>
>`<a class="pure-button pure-button-primary" href="/feeds">Mutasd a legújabb híreket</a>`

Egy másik szakaszban pedig azt láthatjuk, hogy hogyan "álcázzuk" törlés gombnak azt ami csak frissíti a bejegyzést:

>`<form id="delete_user" action="/users/<%= "#{user.id}" %>" method="post">` <br/>
><%= Rack::Csrf.csrf_tag(env) %> <br/>
>`<input type="hidden" name="_method" value="put" />` <br/>
>`<input type="hidden" name="user[is_deleted]" value="<%= true %>" />` <br/>
>`<input type="submit" value="Felhasználó törlés" />` <br/>
>`</form>`

Utolsóként pedig nézzük meg hogy a linkeknek a megjelenítése hogy történik:

><% @links.each do |link| %> <br/>
>`<form action="/link/<%= "#{link.id}" %>" class="pure-form pure-form-stacked" method="post">` <br/>
><%= Rack::Csrf.csrf_tag(env) %> <br/>
>`<input type="hidden" name="_method" value="put" />` <br/>
>`<input id="post_title" name="link[title]" type="text" placeholder="Hivatkozás címe" required="required" pattern="[\s\u00c0-\u00ffA-Za-z0-9 \.,!?]{1,}" data-errormessage-pattern-mismatch="A címben csak betű, szám, pont, vessző, felkiáltójel és kérdőjel lehet, valamint space karakter." value="<%= link.title %>" />` <br/>
>`<div class="entrytext">` <br/>
>`<select name="link[href]">` <br/>
><% unless @selection[0] == nil %> <br/>
><% @selection.each do |select| %> <br/>
>`<option value="/blog/<%= "#{select.id}" %>"><%= select.title %></option>` <br/>
><% end %> <br/>
><% end %> <br/>
>`</select>` <br/>
>`<input type="submit" class="pure-button pure-button-primary" value="Új link létrehozása" />` <br/>
>`</form>` <br/>
>`</div>` <br/>
><% end %>

Lehet látni hogy dupla ciklust használunk, egyet az összes link megjelenítéséhez, egyet pedig a legördülő menük létrehozásához. Csak a meglévő blog bejegyzésekből választhatunk, nehogy valaki idegen linket állítson be. Viszont ha valaki manuálisan módosítaná még akkor is beleütközne a modelljében deklarált reguláris kifejezéssel ami csak az oldalhoz viszonyítva enged meg relatív linkeket létrehozni:

>validates :href, format: { with: /(\A[\[a-z0-9\/]{1,}\z|\A\s\z)/ }

Dióhélyban ennyi az oldal működésének áttekintése.

Bármilyen kérdés lenne az oldal kapcsán, később lesz egy külön oldal a technikai kérdések megválaszolására. A türelmüket kérem amíg megépül.

###After the detailed tutorial on how to create and manage this site will be made, the English readme will be also added.###

How to use:

Install dependencies (bundle)

`migrate (rake db:migrate)`

Run Application (`ruby core.rb`)

Also, make sure to check the following:

`rake -T`

use Ruby 2.0.0 or greater

change session cookie secret

set up database yaml file

create a new user and remove the default one

