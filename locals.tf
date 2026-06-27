locals {
  instance_user_data = replace(
    replace(
      var.instance_user_data_template,
      "BUCKET_NAME",
      var.s3_bucket_name
    ),
    "OBJECT_KEY",
    var.s3_object_key
  )
}
