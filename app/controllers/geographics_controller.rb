class GeographicsController < ApplicationController
  before_filter :initialize_rsolr

  def index
    @page_title = I18n.t(:geographics_link)
    @map = Cartographer::Gmap.new('map' , zoom: 2)
    @header = Cartographer::Header.new.to_s
    @range = params[:range] ? params[:range] : "10,20,30,40,50"
    @icons = {
      10 => "/images_#{I18n.locale}/#{I18n.t(:map_pin_blue)}",
      20 => "/images_#{I18n.locale}/#{I18n.t(:map_pin_green)}",
      30 => "/images_#{I18n.locale}/#{I18n.t(:map_pin_yellow)}",
      40 => "/images_#{I18n.locale}/#{I18n.t(:map_pin_orange)}",
      50 => "/images_#{I18n.locale}/#{I18n.t(:map_pin_red)}"
      }
    # defining icons
    gicons = {}
    [10, 20, 30, 40, 50].each do |i|
      temp_icon = Cartographer::Gicon.new( name: "icon_#{i-10}_to_#{i}", image_url: "#{@icons[i]}",
                                           width: 12, height: 20,
                                           shadow_width: 0, shadow_height: 0, #removing shadow
                                           anchor_x: 6, #width/2 
                                           anchor_y: 20)
      gicons[i] = temp_icon
      @map.icons << temp_icon      
    end
    response = @rsolr.find q: "*:*", facet: true, 'facet.field' => 'location_facet', rows: 0, 'facet.limit' => 8
    # debugger
    response.facets.first.items.each do |item|
      # specify icon
      case item.hits
        when 1..10
          icon_in = 10
        when 11..20
          icon_in = 20
        when 21..30
          icon_in = 30
        when 31..40
          icon_in = 40
        else
          icon_in = 50
      end
      
      if @range.include?(icon_in.to_s)
       
        values= item.value.split(",") #"city, longitude, latitude"
        #inverted the indecies in the solr query ("to match the fake data in the solr core")
        location= Location.get_by_lattitude_and_longitude(values[-1].to_f, values[-2].to_f ).first
        
        @map.markers << Cartographer::Gmarker.new( marker_type: "Building",
                          position: [location.latitude,location.longitude],
                          info_window_url: "/geographics/show/#{location.id}",
                          icon: gicons[icon_in]) unless location.nil?

      end
    end
  end
  
  def show

    location = Location.find_by_id(params[:id])
    @location_name = location.formatted_address unless location.nil?
    response = @rsolr.find q: "location_search:\"#{location.try(:formatted_address)}\""
    @books = {}
    @books_count = response.total
    response.docs.each do |doc|
      title = BooksHelper.find_field_in_document(doc["job_id"], :title.to_s).first
      @books[doc["job_id"]] = title
    end
      render layout: 'main' # this is a blank layout as I don't need any layout in this action
  end

  private

  def initialize_rsolr
    @rsolr = RSolr.connect :url => SOLR_BOOKS_METADATA
  end
end
