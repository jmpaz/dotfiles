function venv
    if test -d ".venv"
        # echo ".venv exists"
        source .venv/bin/activate.fish
        echo "Virtual environment activated."
    else if test -d venv
        echo "venv exists"
        source venv/bin/activate.fish
        echo "Virtual environment activated."
    else
        echo "Virtual environment not found. Create one? (Y/n)"
        read choice
        switch $choice
            case '' Y y
                echo "Creating a new virtual environment..."
                python -m venv .venv --system-site-packages
                echo "Virtual environment created."
                source .venv/bin/activate.fish
                echo "Virtual environment activated."
            case '*'
                echo "Virtual environment creation cancelled."
        end
    end
end
