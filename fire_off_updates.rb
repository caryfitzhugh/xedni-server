# This should show - in the xedni server
# that even though all the updates get processed really fast, and return.
# The read, will wait until everything is processed before responding.
# Seems to work!

require 'net/http'
puts "sending updates"
(0..100).each do
  Net::HTTP.get(URI.parse("http://localhost:11456/update"))
end
puts "done"

puts "sending read"
Net::HTTP.get(URI.parse("http://localhost:11456/read"))
puts "done"
