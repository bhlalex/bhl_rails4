class CollectionsController < ApplicationController
  include CollectionsHelper
  include BooksHelper
  before_filter :store_location, only: [:show]
  before_filter :check_authentication, only: [:add_book]
  
  def index
    @page_title = I18n.t('collection.collection_title')
    @page = params[:page] ? params[:page].to_i : 1
    
    sql_query = "is_public = true"
    sql_query += " AND title LIKE '%#{params[:search]}%'" if !params[:search].blank?
    @collections = Collection.where(sql_query).paginate(page: @page, per_page: PAGE_SIZE).order(params[:sort_type])
    @collections_total_number = Collection.count(:all, conditions: sql_query)
  end
  
  
  def autocomplete
    @results = Collection.where("title LIKE :title", { title: "#{params[:term]}%" }).group(:title).limit(10).map(&:title) # TODO put it in config
    render json: @results
  end

  def show
    @page_title = I18n.t('collection.show_collection_detail')
    @collection = Collection.find(params[:id])
    if @collection.is_public || authenticate_user(@collection.user_id)
      @collection_id = params[:id]
      # @volume_id = nil
      # @comment = Comment.new
      @user_rate = Rate.load_user_rate(session[:user_id], @collection_id, "collection") || 0.0
      @view = params[:view] ? params[:view] : 'list'
      @page = params[:page] ? params[:page].to_i : 1
      @collection_volumes = @collection.collection_volumes.paginate(page: @page, per_page: PAGE_SIZE).order('position ASC')
      # @total_number = @collection_volumes.count
      @user = User.find(@collection.user_id)
      @url_params = params.clone
    end
  end
  
  def edit
    @page_title = I18n.t('collection.edit_collection_page_title')
    @collection = Collection.find(params[:id])
    authenticate_user(@collection.user_id)
  end

  def update
    @collection = Collection.find(params[:id])
    if authenticate_user(@collection.user_id) && request.env["HTTP_REFERER"].present? &&
      request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
      params[:collection][:photo_name] = Collection.process_collection_photo_name(params[:collection][:photo_name]) if !params[:collection][:photo_name].blank?
      if @collection.update_attributes(Collection.collection_params(params[:collection]))
        flash.now[:notice]=I18n.t('collection.collection_updated')
        flash.keep
        redirect_to controller: :collections, action: :show
        return
      else
        flash.now[:error] = I18n.t('collection.collection_not_updated')
        flash.keep
        render action: :edit
        return
      end
    end
  end

  def move_up
    move_or_delete_book("up")
  end

  def move_down
    move_or_delete_book("down")
  end

  def delete_book
    move_or_delete_book("delete")
  end
  
  def get_or_delete_collection_photo
    @collection = Collection.find(params[:id])
    if (is_logged_in_user?(@collection.user_id) && params[:is_delete].to_i == 1)
      @collection.update_attributes(photo_name: '')
      @collection.delete_photo
      @collection.reload
    end
    respond_to do |format|
      format.html {render :partial => "collections/get_collection_photo"}
    end
  end

  def add_book
    if params[:title]
      col = Collection.new(title: params[:title], description: params[:description], is_public: params[:is_public], user_id: session[:user_id])
      if col.valid?
        col.save
        col_id = col.id
      else        
        flash[:notice] = col.errors.full_messages
        respond_to do |format|
          format.html { render partial: 'layouts/flash' }
        end
      end
    else
      col_id = params[:col_id]
    end
    add_book_to_collection(params[:job_id], col_id) if col_id
  end

  def load
    collections = Collection.where(user_id: session[:user_id])
    disabled = []
    collections.each do |col|
      found = CollectionVolume.where(volume_id: params[:job_id], collection_id: col.id)
      if found.count > 0
        disabled << 1
      else
        disabled << 0
      end
    end
    respond_to do |format|
      format.html { render partial: "books/add_book_to_collection", locals: { job_id: params[:job_id], collections: collections, disabled: disabled } }
    end
  end

  private
 
  def move_or_delete_book(decision)
    collection_volume = CollectionVolume.find(params[:collection_volume_id])
    collection = Collection.find(collection_volume.collection_id)
    if authenticate_user(collection.user_id)
      if decision == "up"
        collection_volume.move_higher
      elsif decision == "down"
        collection_volume.move_lower
      else
        collection_volume.destroy
        flash.now[:notice] = I18n.t('collection.collection_volume_deleted')
        flash.keep
      end
      collection.update_attributes(updated_at: Time.now)
      if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
        redirect_to :back
      else
        redirect_to controller: :collections, action: :index
      end
    end
  end
  
  def add_book_to_collection(job_id, col_id)    
    CollectionVolume.create(volume_id: job_id, collection_id: col_id)
    flash[:notice] = I18n.t('msgs.book_added_to_collection')
    respond_to do |format|
      format.html { render partial: 'layouts/flash' }
    end
  end
end
