defmodule LightwarriorWeb.HyperionLEDMappingLive.Index do
  use LightwarriorWeb, :live_view

  alias Lightwarrior.Hyperion
  #alias Lightwarrior.Hyperion.HyperionLEDMapping
  alias Phoenix.LiveView.AsyncResult
  #alias Lightwarrior.Helper

  @impl true
  def mount(_params, _session, socket) do

    stripes = []

    {:ok, socket
      #|> stream_configure(:stripes, dom_id: &("stripe-#{&1.instance}"))
      #|> stream(:stripes, stripes)
      |> assign(:debug, false)
      |> assign(:selected, nil)
      |> assign(:selected_stripe_data, nil)
      |> assign(:serverinfo, AsyncResult.loading())
      |> assign(:current_config, AsyncResult.loading())
      |> assign(:all_stripes_config, AsyncResult.loading())
      |> start_async(:get_serverinfo, fn -> Hyperion.get_serverinfo() end)
      |> start_async(:get_current_config, fn -> Hyperion.get_current_config() end)
    }
  end

  #@impl true
  #def handle_params(%{"instance" => instance}, _, socket) do
  #  dbg(instance)
  #  {:noreply,
  #   socket
  #   |> assign(:selected, "9")
  #  }
  #end

  @impl true
  def handle_params(params, _url, socket) do
    #{:noreply, apply_action(socket, socket.assigns.live_action, params)}
    dbg(params)

    #%{path: path} = URI.parse(url)
    debug = if Map.has_key?(params, "debug"), do: true, else: socket.assigns.debug
    selected = if Map.has_key?(params, "selected"), do: Map.get(params, "selected")

    socket = assign(socket, :page_title, page_title(socket.assigns.live_action))

    case socket.assigns.all_stripes_config.result do
      nil -> if selected, do: {:noreply, push_patch(socket, to: "/hyperion/ledmappings")}, else: {:noreply, socket}
        _ ->
        case selected do
          nil -> {:noreply, socket}
            _ -> selected_stripe_data = Enum.fetch!(socket.assigns.all_stripes_config.result, String.to_integer(selected));
                 #Enum.fetch!(socket.assigns.all_stripes_config.result, String.to_integer(selected))
                 dbg(selected_stripe_data)
                 {:noreply, socket
                    |> assign(:selected, selected)
                    #|> assign(:selected_stripe_data, Helper.string_keys_to_atom_keys(selected_stripe_data))
                    |> assign(:selected_stripe_data, selected_stripe_data)
                  }
        end
    end

  end

  @impl true
  def handle_async(:get_serverinfo, data, socket) do
    %{serverinfo: serverinfo} = socket.assigns
    #dbg(serverinfo)
    case data do
      {:ok, fetched_serverinfo } ->
          #dbg(fetched_serverinfo)
          {:ok, fetched_serverinfo } = fetched_serverinfo
          #dbg(fetched_serverinfo)
          {:ok, stripes} = Hyperion.collect_stripes(fetched_serverinfo)
          #dbg(stripes)
          {:noreply, socket
            #|> stream(:stripes, Enum.reverse(stripes), at: 0)
            |> assign(:serverinfo, AsyncResult.ok(serverinfo, fetched_serverinfo))
            |> start_async(:get_all_stripes_config, fn -> Hyperion.get_all_stripes_config(stripes) end)
          }
      {:exit, reason} ->
          {:noreply, assign(socket, :serverinfo, AsyncResult.failed(serverinfo, {:exit, reason}))}
    end
  end

  @impl true
  def handle_async(:get_current_config, data, socket) do
    %{current_config: current_config} = socket.assigns
    #dbg(serverinfo)
    case data do
      {:ok, fetched_current_config } ->
          #dbg(fetched_serverinfo)
          {:ok, fetched_current_config } = fetched_current_config
          {:noreply, assign(socket, :current_config, AsyncResult.ok(current_config, fetched_current_config))}
      {:exit, reason} ->
          {:noreply, assign(socket, :current_config, AsyncResult.failed(current_config, {:exit, reason}))}
    end
  end

  @impl true
  def handle_async(:get_all_stripes_config, data, socket) do
    %{all_stripes_config: all_stripes_config} = socket.assigns
    #dbg("all stripe config ready")
    #dbg(data)
    case data do
      {:ok, fetched_all_stripes_config } ->
          {:ok, fetched_all_stripes_config } = fetched_all_stripes_config
          {:noreply, socket
            |> assign(:all_stripes_config, AsyncResult.ok(all_stripes_config, fetched_all_stripes_config))
            |> push_event("data-ready", %{})
            #|> stream(:stripes, fetched_all_stripes_config, reset: true)
          }
      {:exit, reason} ->
          {:noreply, assign(socket, :all_stripes_config, AsyncResult.failed(all_stripes_config, {:exit, reason}))}
    end
  end

  def handle_event("mapping_div_size", %{"width" => width, "height" => height}, socket) do
    # Handle the size information as needed
    #IO.puts("Div width: #{width}, height: #{height}")
    size = %{
      width: width,
      height: height
    }
    IO.puts("size: #{inspect(size)}")
    {:noreply, assign(socket, size: size)}
  end

  def handle_event("mapping_div_position", %{"top" => top, "left" => left}, socket) do
    # Handle the size information as needed
    #IO.puts("Div width: #{width}, height: #{height}")
    position = %{
      top: top,
      left: left
    }
    IO.puts("position: #{inspect(position)}")
    {:noreply, assign(socket, position: position)}
  end

  @impl true
  def handle_event("phx:debug", %{"debug" => debug, "value" => _value}, socket) do
    #{:noreply, assign(socket, debug: debug)}
    {:noreply, socket
      |> assign(debug: debug)
      |> push_event("save-debug", %{debug: debug})
    }
  end

  @impl true
  def handle_event("phx:debug", %{"debug" => debug}, socket) do
    case debug do
      nil -> {:noreply, socket}
      "false" -> {:noreply, assign(socket, debug: false)}
      "true" -> {:noreply, assign(socket, debug: true)}
    end

  end

  defp page_title(:index), do: "Hyperion Led Mappings"
  defp page_title(:edit), do: "Hyperion Led Mappings Edit"

end
