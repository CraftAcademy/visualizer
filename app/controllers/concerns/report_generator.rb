module ReportGenerator
  extend ActiveSupport::Concern
  require 'RMagick'

  include Magick

  DEFAULT_CHART_COLORS = {colors: ['#8DCDC1', '#EB6E44'],
                          marker_color: '#7C786A',
                          font_color: '#7C786A',
                          background_colors: 'transparent'}

  def self.generate(service, params, property)
    basic_stats = get_basic_stats(service, params)
    sources = get_sources(service, params)
    os_sources = get_os_sources(service, params)
    traffic_sources = get_traffic_sources(service, params)
    file_name = "#{property.name.downcase}_week_#{Date.today.strftime('%U')}.png"
    generate_line_graph(basic_stats, file_name)
    generate_pie_chart(sources, file_name)
    generate_net_chart(os_sources, file_name)
    generate_referers_graph(traffic_sources, file_name)
    construct_report(property, file_name, basic_stats, sources)
  end

  private

  def self.construct_report(property, file, dataset, sources)
    #binding.pry
    report = Image.new(600, 800) do
      self.background_color = '#FFF5C3'
      self.interlace = PNGInterlace
    end

    chart = Image.read(File.join('public', 'tmp', "line_#{file}")).first
    pie = Image.read(File.join('public', 'tmp', "pie_#{file}")).first
    spider = Image.read(File.join('public', 'tmp', "spider_#{file}")).first
    referrers = Image.read(File.join('public', 'tmp', "referrers_#{file}")).first
    platforms = Image.read(File.join('app', 'assets', 'images', 'platforms.png')).first.resize_to_fit!(200)
    logo = Image.read(File.join('app', 'assets', 'images', 'basic-logo-450X450.png')).first.resize_to_fit!(100)


    header = Image.new(600, 70) do
      self.background_color = '#8DCDC1'
    end

    title_text = Draw.new
    title_text.annotate(header, 0, 0, 20, 20, "Weekly Insights for #{property.name}") do
      title_text.gravity = NorthWestGravity
      self.pointsize = 20
      self.font_family = 'Arial'
      self.fill = '#FFF5C3'
      self.font_weight = BoldWeight
    end

    sub_title_text = Draw.new
    sub_title_text.annotate(header, 0, 0, 20, 45, "Website URL: #{property.website_url}") do
      sub_title_text.gravity = NorthEastGravity
      self.pointsize = 13
      self.fill = '#EB6E44'
      self.font_weight = BoldWeight
    end

    date_text = Draw.new
    date_text.annotate(header, 0, 0, 20, 45, "Week of  #{Date.today.beginning_of_week.strftime('%B %d')} - #{Date.today.end_of_week.strftime('%B %d')}") do
      date_text.gravity = NorthWestGravity
      self.pointsize = 13
      self.fill = '#EB6E44'
      self.font_weight = BoldWeight
    end


    metrics_text = Draw.new
    metrics_text.annotate(report, 0, 0, 360, 85, 'Traffic Metrics') do
      metrics_text.gravity = NorthWestGravity
      self.pointsize = 20
      self.fill = '#7C786A'
      self.font_weight = BoldWeight
    end

    sessions_text = Draw.new
    sessions_text.annotate(report, 0, 0, 300, 123, "Visits: #{dataset.totals_for_all_results['ga:sessions']}") do
      sessions_text.gravity = NorthWestGravity
      self.pointsize = 16
      self.fill = '#8DCDC1'
      self.font_weight = BoldWeight
    end

    page_views_text = Draw.new
    page_views_text.annotate(report, 0, 0, 300, 148, "Page views: #{dataset.totals_for_all_results['ga:uniquePageviews']}") do
      page_views_text.gravity = NorthWestGravity
      self.pointsize = 16
      self.fill = '#EB6E44'
      self.font_weight = BoldWeight
    end

    new_visitors_text = Draw.new
    new_visitors_text.annotate(report, 0, 0, 300, 173, "#{sources.rows[0][0].pluralize}: #{sources.rows[0][1]}") do
      new_visitors_text.gravity = NorthWestGravity
      self.pointsize = 16
      self.fill = '#8DCDC1'
      self.font_weight = BoldWeight
    end

    returning_visitors_text = Draw.new
    returning_visitors_text.annotate(report, 0, 0, 300, 198, "#{sources.rows[1][0].pluralize}: #{sources.rows[1][1]}") do
      returning_visitors_text.gravity = NorthWestGravity
      self.pointsize = 16
      self.fill = '#EB6E44'
      self.font_weight = BoldWeight
    end

    promo_text = Draw.new
    promo_text.annotate(report, 0, 0, 0, 5, 'Generated by Analytics Visualizer by Craft Academy Labs'.upcase) do
      promo_text.gravity = SouthGravity
      self.pointsize = 10
      self.font_family = 'Arial'
      self.fill = '#EB6E44'
      self.font_weight = BoldWeight
    end

    report.composite!(header, 0, 0, OverCompositeOp)
    report.composite!(chart, 10, 80, OverCompositeOp)
    report.composite!(spider, 60, 285, OverCompositeOp)
    report.composite!(referrers, 10, 495, OverCompositeOp)
    report.composite!(pie, 300, 280, OverCompositeOp)
    report.composite!(platforms, 25, 285, OverCompositeOp)
    report.composite!(logo, SouthGravity, OverCompositeOp)

    #report.composite!(promo, SouthGravity, OverCompositeOp)

    report.write(File.join('public', 'tmp', file))
    return "/tmp/#{file}"
  end

  def self.get_basic_stats(service, params)
    profile_id = "ga:#{params[:profile_id]}"
    start_date = Date.today.beginning_of_week.strftime('%F')
    end_date = Date.today.end_of_week.strftime('%F')
    metrics = 'ga:sessions, ga:uniquePageviews'
    data = service.get_ga_data(profile_id, start_date, end_date, metrics, {
        dimensions: 'ga:date'
    })
    return data
  end

  def self.get_sources(service, params)
    profile_id = "ga:#{params[:profile_id]}"
    start_date = Date.today.beginning_of_week.strftime('%F')
    end_date = Date.today.end_of_week.strftime('%F')
    metrics = 'ga:sessions'
    data = service.get_ga_data(profile_id, start_date, end_date, metrics, {
        dimensions: 'ga:userType'
    })
    return data
  end

  def self.get_os_sources(service, params)
    profile_id = "ga:#{params[:profile_id]}"
    start_date = Date.today.beginning_of_week.strftime('%F')
    end_date = Date.today.end_of_week.strftime('%F')
    metrics = 'ga:sessions'
    data = service.get_ga_data(profile_id, start_date, end_date, metrics, {
        dimensions: 'ga:operatingSystem'
    })
    return data.rows.sort! { |a, b| a[1].to_i <=> b[1].to_i }.reverse
  end

  def self.get_traffic_sources(service, params)
    profile_id = "ga:#{params[:profile_id]}"
    start_date = Date.today.beginning_of_week.strftime('%F')
    end_date = Date.today.end_of_week.strftime('%F')
    metrics = 'ga:pageviews'
    data = service.get_ga_data(profile_id, start_date, end_date, metrics, {
        dimensions: 'ga:source',
        filters: 'ga:medium==referral',
        sort: 'ga:pageviews'
    })
    return data
  end

  def self.generate_line_graph(dataset, file_name)
    labels = {}
    visits = []
    page_views = []
    dataset.rows.each_with_index { |d, i| labels[i] = Date.parse(d[0]).strftime('%d/%m') }
    dataset.rows.each { |data| visits.push data[1].to_i }
    dataset.rows.each { |data| page_views.push data[2].to_i }

    line = Gruff::Line.new(265)
    line.theme = DEFAULT_CHART_COLORS
    line.title = 'Visits and Page Views'
    line.labels = labels
    line.data :Visits, visits
    line.data :Page_Vievs, page_views
    line.show_vertical_markers = true
    line.left_margin=10.0
    line.right_margin=10.0
    line.write(File.join('public', 'tmp', "line_#{file_name}"))
  end

  def self.generate_pie_chart(sources, file_name)
    pie = Gruff::Pie.new(265)
    pie.theme = DEFAULT_CHART_COLORS
    pie.title = 'Returning vs New Visitors'
    pie.data sources.rows[0][0].pluralize.to_sym, sources.rows[0][1].to_i
    pie.data sources.rows[1][0].pluralize.to_sym, sources.rows[1][1].to_i
    pie.left_margin = 0
    pie.right_margin = 0
    pie.write(File.join('public', 'tmp', "pie_#{file_name}"))
  end

  def self.generate_net_chart(os_sources, file_name)
    labels = {}
    os_sources[0..4].each_with_index { |d, i| labels[i] = d[0] }
    net = Gruff::Spider.new(os_sources[0][1].to_i.round(-1)*1.1, 265)
    net.theme = DEFAULT_CHART_COLORS
    net.legend_font_size = 30
    net.labels = labels
    net.top_margin = 45
    net.left_margin = 30
    net.right_margin = 30
    os_sources[0..4].each { |data| net.data data[0].to_sym, data[1].to_i }
    net.write(File.join('public', 'tmp', "spider_#{file_name}"))
  end

  def self.generate_referers_graph(traffic_sources, file_name)
    labels = {}
    traffic_sources.rows.reverse[0..4].each_with_index { |d, i| labels[i] = d[0] }
    line = Gruff::SideBar.new(265)
    line.theme = DEFAULT_CHART_COLORS
    line.title = 'Top Referring Sites'
    line.labels = labels
    line.hide_legend=true
    traffic_sources.rows.reverse[0..4].each { |data| line.data data[0], data[1].to_i }
    line.labels = labels
    line.maximum_value= (traffic_sources.rows.reverse[0][1].to_i*1.10).to_i.round(-1)
    line.minimum_value= 10
    line.use_data_label=true
    line.show_labels_for_bar_values = true
    line.left_margin=0
    line.right_margin=0
    line.write(File.join('public', 'tmp', "referrers_#{file_name}"))
  end
end