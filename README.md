# Federal Offense

Federal Offense intercepts outbound emails in Rails and allows you to preview them in your browser. It's like Rails mailer previews, but it doesn't make you write code. It's like Mailcatcher, but doesn't install Eventmachine and can be run inside a Docker container without problems.

<div style="margin: 1em 3em;">

![Screenshot of Federal Offense inbox](https://github.com/flipsasser/federal_offense/blob/master/screenshot.png?raw=true)

</div>

### Table of contents

aka "Proof that I love you"

1. [Installation](#installation)
2. [Usage](#usage)
3. [Reason this Exists](#why-does-this-exist)
4. [Switching from Mailcatcher](#switching-from-mailcatcher)
5. [OH MY GOD THIS SECTION IS SO IMPORTANT WHY IS IT NEAR THE END OF THE README](#production-warning-for-the-love-of-god-heed-mine-words)
6. [Contributing](#contributing)
7. [Leesawns](#license)

## Installation

Federal Offense assumes you're on the latest Rails (Rails 6). It does this because I'm using the latest Rails (Rails 6).

I am in no way opposed to it working for olders Railses (Rails not-6), but I don't really know why you'd bother. Then again, nothing it uses is new. Whatever. Your call. I'd love a pull request. I'd love just to chat, to be honest. It's lonely in quarantine.

Aaaaaaanyway, add it to your Gemfile **in the development environment**:

```ruby
group :development do
  gem "federal_offense"
end
```

Also I've seen people do this; I don't love it for maintenance reasons but you're welcome to do, like, whatever you want:

```ruby
gem "federal_offense", group: :development
```

Right, now run `bundle install`. Obviously. You knew that.

## Usage

Okay! Let's talk about using the thing, shall we?

Once you've [installed it](#Installation), the only thing you *must* do is add it to your routes:

```ruby
Rails.application.routes.draw do
  resources :doodads
  mount FederalOffense::Engine => "/deliveries" if Rails.env.development? # This is the super important part
end
```

After that, when your dev server is running, you can access every outbound email by visiting [`http://localhost:3000/deliveries`](http://localhost:3000/deliveries). So generate an email and refresh that URL.

### ActionCable

Just so's you know, if your app uses ActionCable, Federal Offense will try to use it, too. The end result is an inbox that auto-updates as emails come in. It will piggyback on your app's `cable.yml` configuration, which I figure is safe in development. If you're a real grump, you can copy `config/cable.yml` to `config/federal_offense_cable.yml` and add your own stuff there.

Anyhoo, that's that.

### Caching

Federal Offense caches all of your email as JSON in `tmp/federal_offense`. You may want to blast that out periodically. One option is to run

```sh
rails federal_offense:clear_inbox
```

...which will, you know, get rid of those pesky files. Maybe I'll add some auto-cache-clearing in the future; I dunno, I'm sleepy.

## Why does this exist????

This is here because, FFS, previewing email in Rails is important. Since time immemorial, Mailcatcher has been the gold standard - and it very much still is, *especially* if you're not using Rails (but if you're not using Rails, you can **very, very, VERY safely close this browser tab** because I am adding no value to your life whatsoever).

**HOWEVER,** it's a real PITA to point a Docker instance to a Mailcatcher SMTP server. So I did this instead. Enjoy. Or don't; I don't actually care.

## Switching from Mailcatcher

If you've been using Mailcatcher and want to stop, which for the record I think Mailcatcher is an absolutely amazing library that has made my life infinitely better for years and should by all means continue to be used by you and everyone else you know, including the people you know who don't know how to write code or what Mailcatcher or SMTP is, which is probably most of them, you should know that FederalOffense **does not spin up an SMTP server.**

What this means for you, practically, is that you may have done one, possibly, two things. Those things are:

1. Set `raise_delivery_errors` to `true` somewhere in your environments (presumably `config/environments/development.rb`). If that's the case, **you may want to switch that back off if you're pointing to a Mailcatcher SMTP server you no longer intend to use, which again, use Mailcatcher it's freakin awesome, even though this gem was specifically designed to replace it which doesn't mean I don't absolutely love that gem or the people who made it.**
2. Configured `smtp_settings` to point to Mailcatcher, also probably in `config/environments/development.rb`. If that's the case, you can maybe delete that? I dunno. Your call.

Anyhoo. The important thing is **Federal Offense will not boot an SMTP server so if you turn Mailcatcher off and keep pointing to its (now-disappeared) SMTP endpoint, you will be disappointed**.

## PRODUCTION WARNING FOR THE LOVE OF GOD HEED MINE WORDS

As I've covered exhaustively thus far, this is a Rails engine which makes **all of the email** your app generates **available** at a **publicly accessible URL.** What this means for you is, **NEVER EVER EVER EVER EVER EVER EVER EVER EVER** let this thing leak out into production.

1. **ALWAYS** ensure it lives in the `development` group of your Gemfile.
2. **ALWAYS** add an `if defined?(FederalOffense)` or `if Rails.env.development?` guard before you mount it in `routes.rb`
3. **NEVER** come crying to me when you deploy it to production and, yup, it hits an `abort` tripwire that I added to ensure you don't accidently expose all of your app's private communication to the universe. I mean, I'm all about radical transparency but like... don't be silly.

## Contributing

Create a pull request. This is a simple little library with ~~no test coverage~~ some test coverage (gosh). Oh I should write tests. I normally do. I just, you know... didn't this time.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
