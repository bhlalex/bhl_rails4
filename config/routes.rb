BhlRails4::Application.routes.draw do
  scope "(:locale)", :locale => /en|ar/ do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end



    root :to => 'pages#home'
    get "users/activate/:guid/:activation_code" => "users#activate"
    get "users/reset_password/:guid/:activation_code" => "users#reset_password"
    get "rating/rate/:value/:rateable_type/:user_id/:rateable_id" => "rating#rate"
    get "rating/detailed_rate/:rateable_id/:rateable_type" => "rating#detailed_rate"
    get "user_search_history/save_query"
    get "user_search_history/delete_query"
    get "user_search_history/remove_book_history"
    get "carousel/index"
    get "carousel/get_carousel"
    get "comments/insert_comment"
    get "comments/get_comments"
    get "comments/mark"
    get "comments/delete"
    get "names/show"
    get "names/get_content/:id" => "names#get_content"
    get "get_or_delete_collection_photo" => "collections#get_or_delete_collection_photo"
    get "/collectionautocomplete" => "collections#autocomplete"
    resources :books do
      collection do
        get 'autocomplete'
      end
    end

    resources :users do
      collection do
        get 'login'
        get 'forgot_password'
        post 'validate'
        post 'recover_password'
        post 'reset_password_action'
      end
      member do
        get 'logout'
        get 'get_user_profile_photo'
      end
    end


    resources :pages do
      collection do
        get 'about'
        get 'home'
        get 'contact'
        get 'top_rated_books'
        post 'send_contact_us_message'
      end
    end

    resources :activities do
      collection do
        get 'get_activity_log'
      end
    end    

    resources :names, only: [:index]

    resources :geographics
    get "/geographics/show/:id" => "geographics#show"
    get "/geographics/index/:range" => "geographics#index"

    resources :collections do
      collection do
        get 'add_book'
        get 'load'
        get "/collections/:id/edit" => "collections#edit"
        get "/collections/move_up/:collection_volume_id" => "collections#move_up"
        get "/collections/move_down/:collection_volume_id" => "collections#move_down"
        get "/collections/delete_book/:collection_volume_id" => "collections#delete_book"
      end
    end
    
    resources :comments, only: [:create]
    
    get "hadoop/pending_metadata"
    post "hadoop/ingest_metadata", to: 'hadoop#ingest_metadata'
    get "hadoop/pending_content"
  end
  
  get "darviewer/user"
  get "darviewer/book"
  get "darviewer/annotations"
end
