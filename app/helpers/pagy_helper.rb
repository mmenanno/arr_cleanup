# frozen_string_literal: true

module PagyHelper
  def pagy_tailwind_nav(pagy, pagy_id: nil, link_extra: "", **vars)
    html = +%(<nav class="flex items-center justify-center gap-2"#{%( id="#{pagy_id}") if pagy_id} aria-label="pager">)

    # Previous button
    html << if pagy.prev
      %(<a href="#{pagy.page_url(pagy.prev)}" #{link_extra} class="relative inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold text-gray-300 ring-1 ring-inset ring-gray-700 hover:bg-gray-700 cursor-pointer" aria-label="previous">Previous</a>)
    else
      %(<span class="relative inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold text-gray-500 ring-1 ring-inset ring-gray-700 cursor-not-allowed">Previous</span>)
    end

    # Page numbers
    pagy.series.each do |item|
      case item
      when Integer
        html << if item == pagy.page
          %(<span aria-current="page" class="relative inline-flex items-center rounded-md px-4 py-2 text-sm font-semibold text-white bg-indigo-600 cursor-default">#{item}</span>)
        else
          %(<a href="#{pagy.page_url(item)}" #{link_extra} class="relative inline-flex items-center rounded-md px-4 py-2 text-sm font-semibold text-gray-300 ring-1 ring-inset ring-gray-700 hover:bg-gray-700 cursor-pointer" aria-label="page #{item}">#{item}</a>)
        end
      when String
        html << %(<span class="relative inline-flex items-center px-4 py-2 text-sm font-semibold text-gray-500">#{item}</span>)
      end
    end

    # Next button
    html << if pagy.next
      %(<a href="#{pagy.page_url(pagy.next)}" #{link_extra} class="relative inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold text-gray-300 ring-1 ring-inset ring-gray-700 hover:bg-gray-700 cursor-pointer" aria-label="next">Next</a>)
    else
      %(<span class="relative inline-flex items-center rounded-md px-3 py-2 text-sm font-semibold text-gray-500 ring-1 ring-inset ring-gray-700 cursor-not-allowed">Next</span>)
    end

    html << "</nav>"
    html
  end
end
