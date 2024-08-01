module ApplicationHelper
  include Pagy::Frontend

  def boolean_options(labels: {yes: "Yes", no: "No"}, values: {yes: true, no: false})
    labels.map { |key, label| [label, values[key]] }
  end

  def boolean_options_with_empty(config = {labels: {'': "", yes: "Yes", no: "No"}, values: {yes: true, no: false}})
    config[:labels].map { |key, label| [label, config[:values][key]] }
  end

  # Generates button tags for Turbo disable with
  # Preserve opacity-25 opacity-75 during purge
  def button_text(text = nil, disable_with: t("processing"), &block)
    text = capture(&block) if block

    tag.span(text, class: "when-enabled") +
      tag.span(class: "when-disabled") do
        render_svg("icons/spinner", styles: "animate-spin inline-block h-4 w-4 mr-2") + disable_with
      end
  end

  def checked_svg_filled(id: "", classes: "")
    "
      <svg id='#{id}' class='text-green-500 inline-block w-4 h-4 #{classes}' aria-hidden='true' xmlns='http://www.w3.org/2000/svg' width='24' height='24' fill='currentColor' viewBox='0 0 24 24'>
        <path fill-rule='evenodd' d='M2 12C2 6.477 6.477 2 12 2s10 4.477 10 10-4.477 10-10 10S2 17.523 2 12Zm13.707-1.293a1 1 0 0 0-1.414-1.414L11 12.586l-1.793-1.793a1 1 0 0 0-1.414 1.414l2.5 2.5a1 1 0 0 0 1.414 0l4-4Z' clip-rule='evenodd'/>
      </svg>
    ".html_safe
  end

  def currency_code_options(label: "name", value: "iso_code")
    Money::Currency.table.values.map { |v| [v[label.to_sym], v[value.to_sym]] }
  end

  def datetime_display(date, format = "%b %d, %Y")
    date.respond_to?(:strftime) ? date.strftime(format) : date
  end

  def disable_with(text)
    "<i class=\"far fa-spinner-third fa-spin\"></i> #{text}".html_safe
  end

  def enabled
    render "shared/enabled"
  end

  def humanize_bool(bool = nil)
    return "NA" if bool.nil?

    {true: "Yes", false: "No"}[bool.to_s.to_sym]
  end

  def loader_svg(id: "", classes: "")
    "
      <svg id='#{id}' class='text-blue-700 inline-block h-4 w-4 animate-spin #{classes}' xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' role='img' aria-labelledby='amwb7ugd968kpb56uc2wpox50n2qwl9p'>
        <circle class='opacity-25' cx='12' cy='12' r='10' stroke='currentColor' stroke-width='4'></circle>
        <path class='opacity-75' fill='currentColor' d='M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z'></path>
      </svg>
    ".html_safe
  end

  def render_svg(name, options = {})
    options[:title] ||= name.underscore.humanize
    options[:aria] = true
    options[:nocomment] = true
    options[:class] = options.fetch(:styles, "fill-current text-gray-500")

    filename = "#{name}.svg"
    inline_svg_tag(filename, options)
  end

  def status_badge_classes(status)
    {
      analyzing: "text-blue-700 bg-sky-50 border-sky-200 analyzing",
      uploading: "text-slate-700 bg-slate-50 border-slate-200 uploading",
      review_needed: "text-yellow-800 bg-yellow-50 border-yellow-200 review_needed",
      reviewed: "text-green-700 bg-green-50 border-green-200 reviewed",
      on_hold: "text-red-700 bg-red-50 border-red-200 on_hold"
    }[status.to_sym]
  end

  # fa_icon "thumbs-up", weight: "fa-solid"
  # <i class="fa-solid fa-thumbs-up"></i>
  def fa_icon(name, options = {})
    weight = options.delete(:weight) || "fa-regular"
    options[:class] = [weight, "fa-#{name}", options.delete(:class)]
    tag.i(nil, **options)
  end

  # <%= badge "Active", color: "bg-green-100 text-green-800" %>
  # <%= badge color: "bg-green-100 text-green-800", data: {controller: "tooltip", tooltip_controller_value: "Hello"} do
  #   <svg>...</svg>
  #   Active
  # <% end %>
  def badge(text = nil, options = {}, &block)
    text, options = nil, text if block
    base = options.delete(:base) || "rounded py-0.5 px-2 text-xs inline-block font-semibold leading-normal mr-2"
    color = options.delete(:color) || "bg-gray-100 text-gray-800"
    options[:class] = Array.wrap(options[:class]) + [base, color]
    tag.div(text, **options, &block)
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def viewport_meta_tag(content: "width=device-width, initial-scale=1", turbo_native: "maximum-scale=1.0, user-scalable=0")
    full_content = [content, (turbo_native if turbo_native_app?)].compact.join(", ")
    tag.meta name: "viewport", content: full_content
  end

  def first_page?
    @pagy.page == 1
  end
end
