# Rails Resource Routing: Update

## Learning Goals

- Update a resource using Rails
- Define custom routes in addition to `resources`

## Introduction

In this lesson, we'll continue working on our Bird API by adding an `update`
action, so that clients can use our API to update birds. To get set up, run:

```console
$ bundle install
$ rails db:migrate db:seed
```

This will download all the dependencies for our app and set up the database.

| HTTP Verb    | Path       | Controller#Action | Description            |
| ------------ | ---------- | ----------------- | ---------------------- |
| GET          | /birds     | birds#index       | Show all birds         |
| POST         | /birds     | birds#create      | Create a new bird      |
| GET          | /birds/:id | birds#show        | Show a specific bird   |
| PATCH or PUT | /birds/:id | birds#update      | Update a specific bird |
| DELETE       | /birds/:id | birds#destroy     | Delete a specific bird |

## Video Walkthrough

<iframe width="560" height="315" src="https://www.youtube.com/embed/Q_ddDjw1hQ8?rel=0&amp;showinfo=0" frameborder="0" allowfullscreen></iframe>

## Adding Features

Our birding app has grown wildly in popularity, which means it's time to add a
new feature to keep our users happy! Market research suggests we can increase
user engagement by adding a "like" feature to our application. To do this,
we'll need to update our `Bird` model to keep track of the number of likes.

We'll also need to create a new API endpoint so that users can update the number
of likes for a specific bird.

## Changing Our Model With Migrations

Let's start by creating a new migration to update our `Bird` model and the
associated `birds` table:

```console
$ rails g migration AddLikesToBird likes:integer --no-test-framework
```

> Note: the `--no-test-framework` argument isn't actually needed in this case
> because the Rails migration generator does not create tests. However, it
> doesn't hurt to include it so we do so to encourage the habit.

This will create a new migration file for updating our `birds` table with a new
column for `likes`. Let's also add a default value of 0 likes, and ensure we're
not permitting null values to be saved to the likes column:

```rb
class AddLikesToBird < ActiveRecord::Migration[6.1]
  def change
    add_column :birds, :likes, :integer, null: false, default: 0
  end
end
```

> For a refresher on migrations, check out the
> [Active Record docs][active record migrations]!

Next, run the migration:

```console
$ rails db:migrate
```

We'll also want to re-seed our database. You can do so with this command:

```console
$ rails db:reset
```

This will drop our old development database, and re-create it from scratch based
on our schema and seed file.

With our data set up, let's turn to the next action: updating likes!

## Updating Existing Birds

To start, we'll need to create a new route and controller action to give our
clients the ability to update birds. Recall that following RESTful conventions,
we'll want to set up a `PATCH /birds/:id` route. Just like for our `show` route,
we need the ID in the URL to identify **which** bird is being updated.

We can use `resources` to add this route by adding the `:update` action in our
`routes.rb` file:

```rb
resources :birds, only: [:index, :show, :create, :update]
```

Next, add an `update` action in our controller. Our goal in this action is to:

- find the bird that matches the ID from the route params
- update the bird using the params from the body of the request

```rb
class BirdsController < ApplicationController

  # rest of actions here...

  # PATCH /birds/:id
  def update
    bird = Bird.find_by(id: params[:id])
    if bird
      bird.update(bird_params)
      render json: bird
    else
      render json: { error: "Bird not found" }, status: :not_found
    end
  end

end
```

Just like in the `create` action, we are using strong params when updating the
bird. We can modify the strong params in the `bird_params` method to allow the
`likes` as well:

```rb
def bird_params
  params.permit(:name, :species, :likes)
end
```

Run `rails s` and test out this route in Postman. Try updating the likes for one
specific bird:

```txt
PATCH /birds/1


Headers
-------
Content-Type: application/json


Request Body
------
{
  "likes": 1
}
```

## Creating Custom Routes

One drawback to the approach for our likes feature is that our frontend is
required to keep track of the current number of likes, and do the work of
incrementing that number before sending the request with the updated number of
likes.

We could take some of that burden off of the frontend by providing a **custom
route** that will do the work of calculating the number of likes and
incrementing it, so that all the frontend has to do is send a request to our new
custom route, without worrying about sending any data in the body of the
request.

Update the `routes.rb` file like so:

```rb
Rails.application.routes.draw do
  resources :birds, only: [:index, :show, :create, :update]
  patch "/birds/:id/like", to: "birds#increment_likes"
end
```

Then create the `increment_likes` controller action:

```rb
def increment_likes
  bird = Bird.find_by(id: params[:id])
  if bird
    bird.update(likes: bird.likes + 1)
    render json: bird
  else
    render json: { error: "Bird not found" }, status: :not_found
  end
end
```

Notice that in this action, the only information we need from `params` is the
`id`; we're able to use the bird's current number of likes to calculate the next
number of likes! Our client app no longer needs to concern itself with sending
that data or performing that calculation.

> A note on breaking convention: by creating this custom route, we are breaking
> the REST conventions we had been following up to this point. One alternate way
> to structure this kind of feature and keep our routes and controllers RESTful
> would be to create a new controller, such as Birds::LikesController, and add a
> `create` action in this controller. The creator of Rails, DHH, advocates for
> [this approach for managing sub-resources][dhh controllers].

## Conclusion

Continuing on our journey with REST and CRUD, we've seen how to update a record,
using `PATCH /birds/:id`. We also saw how to break RESTful conventions and
create a custom route.

## Resources

- [Active Record Migrations][active record migrations]
- [How DHH Organizes His Rails Controllers][dhh controllers]

[active record migrations]: https://guides.rubyonrails.org/active_record_migrations.html
[dhh controllers]: http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/
