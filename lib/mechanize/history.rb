class Mechanize
  ##
  # This class manages history for your mechanize object.
  #
  # Since this class inherits Array, you can get the last page by {#last},
  # or iterate over the pages by {#each}.
  class History < Array
    # The number of pages it can contain.
    attr_accessor :max_size

    # Creates a new History object.
    # @param [Integer, nil] max_size The maximum number of pages
    #   it memorizes. When nil, unlimited number of pages will be cached.
    def initialize(max_size = nil)
      @max_size       = max_size
      @history_index  = {}
    end

    # Called by history.clone
    # @private
    def initialize_copy(orig)
      super
      @history_index = orig.instance_variable_get(:@history_index).dup
    end

    # Add a page to the history.
    # Old pages are removed from the history when the
    # number of pages exceeds {#max_size}.
    # @param [Page] page
    # @param [String] uri
    # @return [self]
    def push(page, uri = nil)
      super(page)
      @history_index[(uri ? uri : page.uri).to_s] = page
      if @max_size && self.length > @max_size
        while self.length > @max_size
          self.shift
        end
      end
      self
    end
    alias :<< :push # alias of {#push}

    # Returns true if the given url is in the history.
    # @param [String] url
    # @return [Boolean]
    def visited?(url)
      ! visited_page(url).nil?
    end

    # Returns the Page object corresponds to the {url}.
    # If the {url} is visited more than once,
    # the Page object of the last visit is returned.
    # Returns nil if the {url} is not in the history.
    # @param [String, Page::Link, File, Page] url
    # @return [Page, nil]
    def visited_page(url)
      @history_index[(url.respond_to?(:uri) ? url.uri : url).to_s]
    end

    # Removes all the pages from the history.
    # @return [self]
    def clear
      @history_index.clear
      super
    end

    # Removes the first page and returns it.
    # Returns nil if it has no pages.
    # @return [Page, nil]
    def shift
      return nil if length == 0
      page    = self[0]
      self[0] = nil
      super
      remove_from_index(page)
      page
    end

    # Removes the last page and returns it.
    # Returns nil if it has no pages.
    # @return [Page, nil]
    def pop
      return nil if length == 0
      page = super
      remove_from_index(page)
      page
    end

    private
    def remove_from_index(page)
      @history_index.each do |k,v|
        @history_index.delete(k) if v == page
      end
    end
  end
end
