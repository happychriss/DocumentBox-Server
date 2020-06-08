Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

    resources :connectors

    resources :covers

    ## Upload Sorting, non HABTM
    get 'show_status' => 'status#show_status'
    get 'sorting/destroy_page' => 'upload_sorting#destroy_page'
    get 'show_cover_pages/(:id)' => 'covers#show_cover_pages'
    get 'upload_sorting/download_pdf/(:id)' => 'upload_sorting#download_pdf', :as => :download_pdf

    ### Upload from Client
    ### called from scanner drb daemon ####
    post 'scan_status' =>  'uploads#scan_status'
    post 'create_from_scanner_jpg' => 'uploads#create_from_scanner_jpg', :as => :create_from_scanner_jpg
    post 'create_from_upload' => 'uploads#create_from_upload'
    post 'upload_mobile' => 'uploads#create_from_mobile_jpg',:as => :upload_mobile
    ### called from converter drb daemon ####
    post 'convert_status' =>  'uploads#convert_status'
    post 'convert_upload_preview_jpgs' =>  'uploads#convert_upload_preview_jpgs'
    post 'convert_upload_pdf' =>  'uploads#convert_upload_pdf'
    get 'cd_server_status_for_mobile' => 'uploads#cd_server_status_for_mobile',:as => :cd_server_status_for_mobile

    ## Search Controller, non HABTM
    get 'pdf_doc/:id' => 'search#show_pdf_document', :as => :pdf_document
    get 'pdf/:id' => 'search#show_pdf_page', :as => :pdf_page
    get 'jpg/:id' => 'search#show_jpg_page', :as => :jpg_page
    get 'rtf/:id' => 'search#show_rtf', :as => :rtf
    get 'original/:id' => 'search#show_original', :as => :original

    post 'add_page' => 'search#add_page'

    get 'search/' => 'search#search'
    get 'found/' => 'search#found'
    get 'show_document_pages/:id' => 'search#show_document_pages',:as => :show_document_pages

    ## Edit Documents controller
    post 'sort_pages' => 'documents#sort_pages'
    get 'documents/remove_page/:id' => 'documents#remove_page'
    get 'documents/destroy_page' => 'documents#destroy_page'
    get 'delete_documents' => 'documents#delete_documents'

    ## Status Controller
    get 'status/clear' => 'status#clear'
    get 'status/start_conversion' => 'status#start_conversion'
    get 'trigger_backup' => 'status#trigger_backup'
    get 'status/try_to_connect' => 'status#try_to_connect'
    get 'search_doc_id' => 'documents#search_doc_id'
    get 'search_page_id' => 'documents#search_page_id'
    get 'search_archive' => 'documents#search_archive'
    get 'get_server_status' => 'status#get_server_status'
    post 'get_docbox_status' => 'status#get_docbox_status'

    post 'status_drb' => 'status#status_drb'

    ## Scanner Controller
    get "scanners/scan_info"

    ### called from scanner drb daemon ####
    post 'start_scanner' => 'scanners#start_scanner'
    post 'start_scanner_from_hardware' => 'scanners#start_scanner_from_hardware'
    post 'start_copy_from_hardware' => 'scanners#start_copy_from_hardware'
    post 'scan_error' =>  'scanners#scan_error'
    post 'scan_info' =>  'scanners#scan_info'



    resources :folders
    resources :tags
    resources :upload_sorting
    resources :documents
    resources :status
    resources :uploads

    #resources :documents do
    #     resources :documents, :uploads
    #end

    root :to => 'search#search'

    # The priority is based upon order of creation:
    # first created -> highest priority.

    # Sample of regular route:
    #   match 'products/:id' => 'catalog#view'
    # Keep in mind you can assign values other than :controller and :action

    # Sample of named route:
    #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    #   resources :products

    # Sample resource route with options:
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

    # Sample resource route with sub-resources:
    #   resources :products do
    #     resources :comments, :sales
    #     resource :seller
    #   end

    # Sample resource route with more complex sub-resources
    #   resources :products do
    #     resources :comments
    #     resources :sales do
    #       get 'recent', :on => :collection
    #     end
    #   end

    # Sample resource route within a namespace:
    #   namespace :admin do
    #     # Directs /admin/products/* to Admin::ProductsController
    #     # (app/controllers/admin/products_controller.rb)
    #     resources :products
    #   end

    # You can have the root of your site routed with "root"
    # just remember to delete public/index.html.
    # root :to => 'welcome#index'

    # See how all your routes lay out with "rake routes"

    # This is a legacy wild controller route that's not recommended for RESTful applications.
    # Note: This route will make all actions in every controller accessible via GET requests.
    # match ':controller(/:action(/:id))(.:format)'



end
