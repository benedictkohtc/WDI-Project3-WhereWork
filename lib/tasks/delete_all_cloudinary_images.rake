# if you need to do seed_from_google_places again and need to clean out
# the existing images in the cloudinary store

task delete_all_cloudinary_images: :environment do

  Cloudinary::Api.delete_all_resources

end
