class PrintRating
  def call(ps, counts)
    # рисуем таблицу
    sorted = ps.sort_by { |_, v| -v.mean }

    labels = sorted.map { |k, _| k }
    data = sorted.map { |_, v| [v.mean, v.mean] }
    kmeans = KMeansClusterer.run(6, data, labels: labels, runs: 10)

    rows = []
    kmeans.clusters.each do |cluster|
      cluster.points.each do |p|
        if ps[p.label].deviation < 2
          rows << [
            cluster.id,
            p.label, 
            ps[p.label].mean,
            counts[p.label], 
            ps[p.label].deviation
          ]
        end
      end
    end

    return "Еще никто не дошел до минимального Deviation" if rows.empty?

    rows.sort_by! { |r| -r[2] }

    table = Terminal::Table.new(headings: ["Name", "Rating", "Games", "Deviation"]) do |t|
      cur = rows[0][0]
      rows.each do |row|
        if cur != row[0]
          t.add_separator 
          cur = row[0]
        end
        row[2] = "%+0.3f" % row[2]
        row[4] = "%+0.3f" % row[4]
        row = row[1..-1]
        t.add_row(row)
      end
    end
    table.style = { border_x: "=", border_y: "|", border_i: "x" }
    table
  end
end
