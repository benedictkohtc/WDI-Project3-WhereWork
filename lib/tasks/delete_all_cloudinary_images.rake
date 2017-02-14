task delete_all_cloudinary_images: :environment do

  Cloudinary::Api.delete_all_resources

end
