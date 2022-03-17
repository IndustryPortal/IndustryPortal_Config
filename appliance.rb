# Appliance ncbo_cron config
# This file should not be modified.  Most of site related settings should be set
# in site_config.rb
require '/srv/ontoportal/virtual_appliance/utils/hostname_lookup.rb'
if File.exist?('config/environments/site_config.rb') || File.exist?('config/site_config.rb')
  require_relative 'site_config.rb'
end

$HOSTNAME = $UI_HOSTNAME = %x[hostname].strip
$REST_HOSTNAME = "data.#{$HOSTNAME}"
$REST_PORT = nil
$REST_URL_PREFIX = "http://#{[$REST_HOSTNAME, $REST_PORT].compact.join(':')}/"
$DATADIR ||= '/srv/ontoportal/data'

GOO_BACKEND_NAME = '4store'
GOO_PORT        = GOO_BACKEND_NAME.include?('AG') ? 10035                                 : 8081
GOO_PATH_QUERY  = GOO_BACKEND_NAME.include?('AG') ? '/repositories/ontoportal'            : '/sparql/'
GOO_PATH_DATA   = GOO_BACKEND_NAME.include?('AG') ? '/repositories/ontoportal/statements' : '/data/'
GOO_PATH_UPDATE = GOO_BACKEND_NAME.include?('AG') ? '/repositories/ontoportal/statements' : '/update/'

begin
  # For prefLabel extract main_lang first, or anything if no main found.
  # For other properties only properties with a lang that is included in main_lang are used
  Goo.main_languages = ["en", "fr"]
  Goo.use_cache = true
rescue NoMethodError
  puts "(CNFG) >> Goo.main_lang not available"
end

begin
  LinkedData.config do |config|
    config.goo_host                   = 'localhost'
    config.goo_port                   = "#{GOO_PORT}"
    config.goo_backend_name           = "#{GOO_BACKEND_NAME}"
    config.goo_path_query             = "#{GOO_PATH_QUERY}"
    config.goo_path_data              = "#{GOO_PATH_DATA}"
    config.goo_path_update            = "#{GOO_PATH_UPDATE}"

    config.java_max_heap_size         = '20480M'

    config.rest_url_prefix            = "#{$REST_URL_PREFIX}"
    config.ui_host                    = "#{$UI_HOSTNAME}"
    config.search_server_url          = 'http://localhost:8983/solr/term_search_core1'
    config.property_search_server_url = 'http://localhost:8983/solr/prop_search_core1'
    config.repository_folder          = "#{$DATADIR}/repository"
    config.replace_url_prefix         = true
    config.enable_security            = true
    config.enable_slices              = true

    # Caches
    Goo.use_cache             = true
    config.goo_redis_host     = "localhost"
    config.goo_redis_port     = 6381
    config.enable_http_cache  = true
    config.http_redis_host    = "localhost"
    config.http_redis_port    = 6380

    # PURL server config parameters
    config.enable_purl            = false
    config.purl_host              = "purl.example.org"
    config.purl_port              = 80
    config.purl_username          = "admin"
    config.purl_password          = "password"
    config.purl_maintainers       = "admin"
    config.purl_target_url_prefix = "http://example.org"

    # Email notifications
    config.enable_notifications   = false 
    config.email_sender           = "industryportal-support@enit.fr" # Default sender$
    config.email_override         = "industryportal-support@enit.fr" # all email gets$
    config.email_disable_override = true
    config.smtp_host              = "smtp.enit.fr"
    config.smtp_port              = 25
    config.smtp_auth_type         = :none # :none, :plain, :login, :cram_md5
    config.smtp_domain            = "lirmm.fr"
    config.admin_emails           = ["industryportal-support@enit.fr"]

    # Ontology Google Analytics Redis
    # disabled
    config.ontology_analytics_redis_host = "localhost"
    config.ontology_analytics_redis_port = 6379

    # Used to define other bioportal that can be mapped to
    # Example to map to ncbo bioportal : {"ncbo" => {"api" => "http://data.bioontology.org", "ui" => "http://bioportal.bioontology.org", "apikey" => ""}
    # Then create the mapping using the following class in JSON : "http://purl.bioontology.org/ontology/MESH/C585345": "ncbo:MESH"
    # Where "ncbo" is the namespace used as key in the interportal_hash
    config.interportal_hash   = {
      
    }
  end
rescue NameError
#  puts '(CNFG) >> LinkedData not available, cannot load config'
end
begin
  Annotator.config do |config|
    config.mgrep_dictionary_file   = "#{$DATADIR}/mgrep/dictionary/dictionary.txt"
    config.stop_words_default_file = './config/default_stop_words.txt'
    config.mgrep_host              = 'localhost'
    config.mgrep_port              = 55555
    config.mgrep_alt_host          = 'localhost'
    # secondary mgrep instance is not configured for appliance. routing all requestes to the primary mgrep
    config.mgrep_alt_port          = 55555
    config.annotator_redis_host    = 'localhost'
    config.annotator_redis_port    = 6379

    # Config for lemmatization
    config.lemmatizer_jar             = [%x[bundle info ncbo_annotator --path].to_s.strip, 'lib', 'Lemmatizer'].join('/')
    config.mgrep_lem_dictionary_file  = "#{$DATADIR}/mgrep/dictionary/dictionary-lem.txt"
    config.mgrep_lem_host             = "localhost"
    config.mgrep_lem_port             = 55557
  end
rescue NameError
#  puts '(CNFG) >> Annotator not available, cannot load config'
end

begin
  OntologyRecommender.config do |config|
  end
rescue NameError
#  puts '(CNFG) >> OntologyRecommender not available, cannot load config'
end

begin
  LinkedData::OntologiesAPI.config do |config|
    config.enable_unicorn_workerkiller = true
    config.enable_throttling           = false
    config.http_redis_host             = LinkedData.settings.http_redis_host
    config.http_redis_port             = LinkedData.settings.http_redis_port
    config.restrict_download           = []
    #config.ontology_rank               = ""
  end
rescue NameError
#  puts '(CNFG) >> OntologiesAPI not available, cannot load config'
end

begin
  NcboCron.config do |config|
    config.redis_host           = Annotator.settings.annotator_redis_host
    config.redis_port           = Annotator.settings.annotator_redis_port
    config.enable_ontology_analytics = false
    config.search_index_all_url = 'http://localhost:8983/solr/term_search_core2'
    config.property_search_server_index_all_url = 'http://localhost:8983/solr/prop_search_core2'
    config.ontology_report_path = "#{$DATADIR}/reports/ontologies_report.json"
    config.enable_spam_deletion = false
  end
rescue NameError
  puts '(CNFG) >> NcboCron not available, cannot load config'
end
