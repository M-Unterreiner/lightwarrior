defmodule LightwarriorWeb.IPlayerLive.IPlayerFormComponent do
  use LightwarriorWeb, :live_component

  alias Lightwarrior.Imageplayer

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <!--<%= @title %>-->
        <:subtitle>Controll Gstreamer to shmdata transmission</:subtitle>
      </.header>

      <div class="flex" >
        <div>
        <.input name="path" value={@path}/>
        <div id="filesystem" phx-hook="DragArea" class="overflow-hidden rounded-lg bg-slate-50 ring-1 shadow p-3 cursor-pointer" >
          <ul>
            <li phx-click="cd" phx-value-name=".." phx-target={@myself}> <b>..</b> </li>
          </ul>
          <ul :if={@dirs}>
            <li
              :for={dir <- @dirs}
              :if={String.at(dir, 0) != "."}
              phx-click="cd"
              phx-value-name={dir}
              phx-target={@myself}
            >
              <b><%= dir %></b>
            </li>
          </ul>
          <ul :if={@files}>
          <li
              :for={file <- @files}
              :if={String.at(file, 0) != "."}
              phx-click="select"
              phx-value-path={@path}
              phx-value-filename={file}
              phx-target={@myself}
              class="draggable"
              draggable="true"
            >
              <%= file %>
            </li>
          </ul>
        </div>
        </div>
      </div>

    </div>
    """
  end

  @impl true
  def update(%{id: "iplayer_file_form", title: "Listing Iplayer", action: :index} = assigns, socket) do
    #changeset = Imageplayer.change_i_player(i_player)

    path = Path.expand("~")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:path, path)
     |> ls()
     #|> assign_form(changeset)
     }
  end

  @impl true
  def handle_event("validate", %{"i_player" => i_player_params}, socket) do
    changeset =
      socket.assigns.i_player
      |> Imageplayer.change_i_player(i_player_params)
      |> Map.put(:action, :validate)

    #{:noreply, assign_form(socket, changeset)}
    {:noreply, socket}
  end

  def handle_event("cd", param, socket) do
    #dbg(get_path(socket, param["name"]))
    socket =
      socket
      |> assign(path: get_path(socket, param["name"]))
      |> ls()

    {:noreply, socket}
  end

  def handle_event("select", param, socket) do
    dbg(param)
    socket =
      socket
      #|> assign(path: path(socket, param[]))
      |> ls()

      notify_parent({:selected, get_path(socket, param["filename"])})

    {:noreply, socket}
  end

  defp ls(socket) do
    case File.ls(socket.assigns.path) do
      {:ok, entries} ->
        {dirs, files} = Enum.split_with(entries,
          fn x ->
            #IO.puts(socket.assigns.path <> "/" <> x)
            File.dir?(socket.assigns.path <> "/" <> x)
          end
        )

        notify_parent({:change_path, get_path(socket, "")})

        assign(socket, dirs: Enum.sort(dirs), files: Enum.sort(files))
        #{dirs, files} = Enum.split_with(entries, &File.dir?(path(socket, &1)))
        #assign(socket, dirs: Enum.sort(dirs), files: Enum.sort(files))
        #socket
      _ ->
        socket
    end
  end

  defp get_path(socket, param) do
    #dbg(socket.assigns.path <> "/" <> param)
    Path.expand(socket.assigns.path <> "/" <> param)
  end

  #defp assign_form(socket, %Ecto.Changeset{} = changeset) do
  #  assign(socket, :form, to_form(changeset))
  #end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end