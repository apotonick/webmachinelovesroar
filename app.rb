require 'bundler/setup'
require 'roar/representer/json'
require 'roar/representer/feature/hypermedia'
require 'webmachine'

class Product
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  
  property :name
  property :id
  property :price

  link :self do
    "/products/#{id}"
  end
end

# We're in-memory ROFLSCALE
$products = [
             Product.from_attributes(:id => 1,
                                     :name => "Nick's Awesomesauce",
                                     :price => 10_000_000)
            ]

class ProductResource < Webmachine::Resource
  def allowed_methods
    if request.path_info[:id]
      %w[GET HEAD]
    else
      %w[POST]
    end
  end

  def resource_exists?
    @product = $products[request.path_info[:id].to_i - 1] if request.path_info[:id]
    !@product.nil?
  end

  def allow_missing_post?
    true
  end
  
  def post_is_create?
    true
  end

  def create_path
    @product = Product.from_attributes(:id => $products.length+1)
    @product.to_json
    @product.links[:self]
  end
  
  def content_types_provided
    [["application/json", :to_json]]
  end

  def content_types_accepted
    [["application/json", :from_json]]
  end

  def from_json
    $products << @product.from_json(request.body.to_s) do |object|
      # TODO: if i fuck up things here, there's no exception - why [@seancribbs]?
      object.definition.name != "id" # and object.definition.name != "links"
    end
  end
  
  def to_json
    @product.to_json
  end
end

Webmachine.routes do
  add ["products"], ProductResource
  add ["products", :id], ProductResource
end.run
