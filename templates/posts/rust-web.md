+++
tags = ["rust", "webdev", "programming"]
created_at = "2017-08-04T10:43:49-04:00"
published_at = "2017-08-04T10:43:49-04:00"
title = "Rust Web-Development, Part 1"

+++
Now that [Hairy Little Buggers](http://store.steampowered.com/app/405240) is wrapped up, I figured I'd use my sabbatical to dive into web-development. This is also a good chance to play with [Rust](http://rust-lang.org) again; the last time I checked it out was before 1.0 when I was playing with the [Matasano crypto challenges](http://cryptopals.com/), so it will be interesting to see how much more mature the ecosystem is.

Now, I don't really know anything about web-development, so after a little research I picked up [Flask Web Development](https://www.amazon.ca/Flask-Web-Development-Developing-Applications/dp/1449372627/ref=sr_1_sc_1?ie=UTF8&qid=1501866858&sr=8-1-spell) based on the [Flask Mega-Tutorial](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world). I know Python fairly well so I can mentally translate the Python into Rust, and [Flask](http://flask.pocoo.org) seems like the framework I would pick were I to write a web app in Python. 

## Framework Selection
Much as I love writing everything myself, sometimes it makes sense to stand on the shoulders of giants. A combination of browsing the rust sub-reddit and searching the web suggested five initial candidates for a web framework:
[Nickel](https://github.com/nickel-org/nickel.rs), 
[Iron](https://ironframework.io), 
[Rocket](https://rocket.rs), 
[Rouille](https://github.com/tomaka/rouille), and 
[Pencil](https://github.com/fengsp/pencil). The following is just my own personal experiences with each framework, and is definitely not meant to be the definitive objective guide to web developent in Rust. In particular, these are my fickle first impressions and snap judgements. Do your own research!

### Rocket
Rocket requires the use of the `nightly` compiler, which annoys me.  A pretty decent fraction of common packages in the Rust ecosystem seemingly still rely on `nightly` rather than `stable`. Using Rust in production is already questionable given it's novelty, and using the `nightly` version of the compiler strikes me as a bridge too far. So Rocket's out.

### Rouille and Pencil
Rouille and Pencil are smaller frameworks, which aligns with my desire to do most of the programming and component selection myself rather than delegating to a monster framework like Rails or Django, so I tried them out next.  Both seem pretty immature though, so after getting my `hello-world` servers up and running it seemed like I would have to build a *lot* myself. At that point the impedance mismatch between my code and the framework makes me want to just write the framework part myself as well. Scratch these two off the list.

### Nickel and Iron
Nickel and Iron seem pretty similar, with more of a batteries-included philosophy then Rouille or Pencil. Iron seems more mature and seems to have more development activity around it, so I picked Iron (sorry Nickel).

I got templating working with [handlebars-iron](https://github.com/sunng87), and was messing around with sessions and forms when I stumbled upon a bug I could not solve. Implementing [Post/Redirect/Get](https://en.wikipedia.org/wiki/Post/Redirect/Get) resulted in something in the stack (I'm not sure if it was [Hyper](https://github.com/hyperium/hyper) or Iron) parsing the incoming GET request as `Method::Extension(user=USERNAME&password=PASSWDGET)`, rather than what I would expect `Method::Get`. It looks like Iron is interpreting the form data as part of the method? Forms a pretty common part of a web app, one would think they would work pretty well. Iron includes handlers to redirect, and a `url_for` function to find the address of routes. After a couple of days of not being able to find a problem on my end, I gave up on Iron. The next step was to start debugging [Iron](https://ironframework.io) and [Hyper](https://github.com/hyperium/hyper) code to figure out why they're not parsing the http request correctly, and pretty much the whole point of a framework is to avoid parsing request headers yourself. You can check out the final state of my iron experiment [here](https://github.com/esnowkropla/iron_test); it's pretty functional, and the P/R/G problem is reasonably well illustrated because the code is so small.

## Pure Hyper
At this point I figured that for a simple CRUD app I don't necessarily need a complete web framework, maybe I can just work off of a bare HTTP server. I have already briefly mentioned [Hyper](https://hyper.rs/); it appears to be THE http server for Rust. After getting it set up and running through the tutorials though, I was confounded by complexity of the traits that are required to be implemented for fielding requests; Hyper appears to be in transition between blocking and async io, and the user interface is still a little hairy. In particular I'm going to need global mutable state at some point (the database), and getting the borrowing working correctly was proving more finicky than I would like.

It was at this point that I considered going below even Hyper, and writing the HTTP server myself from scratch. This is silly; if I want to get anything done I shouldn't rewrite the whole stack myself. The other alternative would be to abandon Rust and just play around with Flask; I could at least build my web apps, even if I wasn't playing with a new(ish) language.

Luckily for me though, as I was searching around for the solution to my latest problem I saw a code example of [Rocket](https://rocket.rs), which I had so quickly dismissed before; and I liked what I saw! Request routing, sessions handling, state handling, with a heavy emphasis on developer experience. A fair bit of magic in the code generation to handle the routing, but implementing the traits in the request guards and the serialization was REALLY easy. Converted, I started up a new project and threw Rocket into the Cargo.toml. This is long enough, so we'll leave off here; next week, actually building things!
