# Heroku Forward

This is designed to allow you to provide access to your local development server over an SSL cert without having to faff around with SSL certs yourself thanks to Heroku's wildcard SSL certificate. You will still need to have a port opened and forwarded (if you're behind a NAT gateway) on the network you're running your development machine on - if you can't do that, consider trying [Forward](https://forwardhq.com).

## Installation

1. Clone this repo.
2. Create your own Heroku app, using the Cedar stack. `heroku apps:create -s cedar`
3. Define two additional config vars FORWARD_HOST and FORWARD_PORT - `heroku config:set FORWARD_HOST="blahblahblah.com" FORWARD_PORT="3000"`
4. Push it to Heroku `git push heroku master`
5. Open your app and behold `heroku apps:open`

It currently doesn't override the 'Host' HTTP header, so Host your development server gets will be whatever the Heroku host is. It was designed to be used with Rails apps that don't (generally) care about such things :)

## License

MIT: http://neutroncreations.mit-license.org/2008