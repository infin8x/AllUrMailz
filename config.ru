require './allurmailz.rb'
use Rack::Session::Cookie, :key => 'rack.session',
                           :domain => 'arapahoebasin.reshall.rose-hulman.edu',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'my super super secret session secret'

run AllUrMailz
