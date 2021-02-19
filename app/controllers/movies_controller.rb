class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  # ver3
  def index

    @all_ratings = Movie.all_ratings
    @ratings_to_show = Array.new
    # Here: when sorting or NON-sorting, the rating info are both referenced by "ratings",
    # !!! params[:home] is set in veiws, to make sure when we unclick all rating checkbox, don't use the session info.
    if params[:home] and params[:ratings]
      # If rating checkbox has been checked, convert the keys of the hash to an array
      @ratings_to_show = params[:ratings].keys
    # When go back to HOME page from other links, use sesseion.
    elsif !params[:home] and session[:ratings]
      @ratings_to_show = session[:ratings].keys
    end
    @movies = Movie.with_ratings(@ratings_to_show)

    @sort = params[:sort]
    # Click Fresh in the HOME page, the sorting will dispear.
    if !params[:home] and session[:sort]
      @sort = session[:sort]
    end
    @movies = @movies.order(@sort)

    # If there are new actions about rating or sorting, update them to sessoin; (@ratings_to_show... obtained from params)
    # If no action, just go back from other links, (@ratings_to_show... obtained from sessions), thus same
    session[:ratings] = Hash[@ratings_to_show.collect {|r| [r, 1]}]
    session[:sort] = @sort
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
