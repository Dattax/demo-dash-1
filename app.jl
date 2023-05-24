using Dash
using CSV
using DataFrames
using Sockets

port = 8888

app = dash()

df = CSV.read(("comm_prices.csv"), DataFrames.DataFrame) 

all_options = Dict(
    names(df)[2] => df[!, 2][1:51],
    names(df)[3] => df[!, 3][1:51],
    names(df)[4] => df[!, 4][1:51],
    names(df)[8] => df[!, 5][1:51],
)

app.layout = html_div() do
    html_h1("World Prices App"),
    html_p("This application shows you data around the average world price of each commodity listed from 1971 to 2021."),
    html_button("Cocoa"),
    html_button("Coffee"),
    html_button("Tea"),
    html_button("Sugar"),
    html_h5("The last 50 years of growth in commodity prices:"),
    dcc_graph(
        id = "all-commodities",
        figure = (
            data = [
                (x = df.Year, y = df.Cocoa, type = "plot", name = "Cocoa"),
                (x = df.Year, y = df.Coffee, type = "plot", name = "Coffee"),
                (x = df.Year, y = df.Tea, type = "plot", name = "Tea"),
                (x = df.Year, y = df.Sugar, type = "plot", name = "Sugar"),
            ],
            layout = (title = "World Commodity Prices",)
        )
    ),
    html_br(),
    html_br(),
    html_div(
        id = "left",
        children = [
            html_h3("Commodity App"),
            html_h5("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi commodo, metus sed facilisis dictum, ipsum risus maximus nisl, at bibend. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi commodo, metus sed facilisis dictum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi commodo, metus sed facilisis dictum."),
            dcc_dropdown(
                id = "commodities",
                options = [(label = i, value = i) for i in keys(all_options)],
                value = "Cocoa",
            ),
        ],
    ),
    html_div(
        id = "right", 
        children = [
            html_div(id = "display-selected-values"),
            html_button("Coffee", id="show-coffee"),
            html_button("Cocoa", id="show-cocoa"),
            html_button("Tea", id="show-tea"),
            html_button("Sugar", id="show-sugar"),
            dcc_dropdown(id = "prices"),
            html_br(),
            html_div(id="body-coffee"),
            html_div(id="body-tea"),
            html_div(id="body-cocoa"),
            html_div(id="body-sugar")
        ],
    )
end

callback!(
    app,
    Output("prices", "options"),
    Input("commodities", "value"),
) do selected_commodity
    return [(label = i, value = i) for i in all_options[selected_commodity]]
end

callback!(
    app,
    Output("prices", "value"),
    Input("prices", "options"),
) do available_options
    return available_options[1][:value]
end

callback!(
    app,
    Output("display-selected-values", "children"),
    Input("commodities", "value"),
    Input("prices", "value"),
) do selected_commodity, selected_price
    return "\$$(selected_price) was the price of $(selected_commodity)"
end

# //////////// Cocoa graph callback

callback!(
    app,
    Output("body-cocoa", "children"),
    Input("show-cocoa", "n_clicks")
) do n_clicks
    if isnothing(n_clicks)
        throw(PreventUpdate())
    end
    return dcc_graph(
        id = "example-graph-cocoa",
        figure = (
            data = [
                (x = df.Year, y = df.Cocoa, type = "plot", name = "Cocoa"),
            ],
            layout = (title = "Cocoa",)
        )
    )
end

# //////////// Coffee graph callback

callback!(
    app,
    Output("body-coffee", "children"),
    Input("show-coffee", "n_clicks")
) do n_clicks
    if isnothing(n_clicks)
        throw(PreventUpdate())
    end
    return dcc_graph(
        id = "example-graph-coffee",
        figure = (
            data = [
                (x = df.Year, y = df.Coffee, type = "plot", name = "Coffee"),
            ],
            layout = (title = "Coffee",)
        )
    )
end

# //////////// Tea graph callback

callback!(
    app,
    Output("body-tea", "children"),
    Input("show-tea", "n_clicks")
) do n_clicks
    if isnothing(n_clicks)
        throw(PreventUpdate())
    end
    return dcc_graph(
        id = "example-graph-tea",
        figure = (
            data = [
                (x = df.Year, y = df.Tea, type = "plot", name = "Tea"),
            ],
            layout = (title = "Tea",)
        )
    )
end

# //////////// Sugar graph callback

callback!(
    app,
    Output("body-sugar", "children"),
    Input("show-sugar", "n_clicks")
) do n_clicks
    if isnothing(n_clicks)
        throw(PreventUpdate())
    end
    return dcc_graph(
        id = "example-graph-sugar",
        figure = (
            data = [
                (x = df.Year, y = df.Sugar, type = "plot", name = "Sugar"),
            ],
            layout = (title = "Sugar",)
        )
    )
end

run_server(app, Sockets.localhost, port, debug=true)

