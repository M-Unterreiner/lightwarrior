defmodule LightwarriorWeb.HyperionLEDMappingLive.Index do
  use LightwarriorWeb, :live_view

  alias Lightwarrior.Hyperion
  #alias Lightwarrior.Hyperion.HyperionLEDMapping
  alias Phoenix.LiveView.AsyncResult
  alias Lightwarrior.Helper

  @impl true
  def mount(_params, _session, socket) do

    stripes = []

    {:ok, socket
      |> stream_configure(:stripes, dom_id: &("stripe-#{&1.instance}"))
      |> stream(:stripes, stripes)
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
  def handle_params(params, url, socket) do
    #{:noreply, apply_action(socket, socket.assigns.live_action, params)}
    dbg(params)

    #%{path: path} = URI.parse(url)
    debug = if Map.has_key?(params, "debug"), do: true, else: socket.assigns.debug
    selected = if Map.has_key?(params, "selected"), do: Map.get(params, "selected")

    case socket.assigns.all_stripes_config.result do
      nil -> if selected, do: {:noreply, push_patch(socket, to: "/hyperion/ledmappings")}, else: {:noreply, socket}
        _ ->
        case selected do
          nil -> {:noreply, socket}
            _ -> selected_stripe_data = Enum.fetch!(socket.assigns.all_stripes_config.result, String.to_integer(selected));
                 "penis"
                 #Enum.fetch!(socket.assigns.all_stripes_config.result, String.to_integer(selected))
                 {:noreply, socket
                    |> assign(:selected, selected)
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
            |> stream(:stripes, Enum.reverse(stripes), at: 0)
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
    dbg("all stripe config ready")
    #dbg(data)
    case data do
      {:ok, fetched_all_stripes_config } ->
          {:ok, fetched_all_stripes_config } = fetched_all_stripes_config
          {:noreply, socket
            |> assign(:all_stripes_config, AsyncResult.ok(all_stripes_config, fetched_all_stripes_config))
            |> stream(:stripes, fetched_all_stripes_config, reset: true)
          }
      {:exit, reason} ->
          {:noreply, assign(socket, :all_stripes_config, AsyncResult.failed(all_stripes_config, {:exit, reason}))}
    end
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

end
