module Rubytus
  module Constants
    RESOURCE_UID_REGEX     = /^([a-z0-9]{32})$/
    BASE_PATH_REGEX        = /^(\/[a-zA-Z0-9\-_]+\/)$/

    RESUMABLE_CONTENT_TYPE = 'application/offset+octet-stream'

    ENV_DATA_DIR           = 'TUSD_DATA_DIR'
    ENV_BASE_PATH          = 'TUSD_BASE_PATH'
    ENV_MAX_SIZE           = 'TUSD_MAX_SIZE'

    DEFAULT_DATA_DIR       = 'tus_data'
    DEFAULT_BASE_PATH      = '/files/'
    DEFAULT_MAX_SIZE       = 1073741824

    STATUS_OK              = 200
    STATUS_CREATED         = 201
    STATUS_BAD_REQUEST     = 400
    STATUS_FORBIDDEN       = 403
    STATUS_NOT_FOUND       = 404
    STATUS_NOT_ALLOWED     = 405
    STATUS_INTERNAL_ERROR  = 500

    INITIAL_HEADERS        = {
      'Content-Type'                  => 'text/plain; charset=utf-8',
      'Access-Control-Allow-Origin'   => '*',
      'Access-Control-Allow-Methods'  => 'HEAD,GET,PUT,POST,PATCH,DELETE',
      'Access-Control-Allow-Headers'  => 'Origin, X-Requested-With, Content-Type, Accept, Content-Disposition, Final-Length, Offset',
      'Access-Control-Expose-Headers' => 'Location, Range, Content-Disposition, Offset'
    }
  end
end
