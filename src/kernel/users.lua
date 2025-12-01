local Users = {}
local VFS = require("src.kernel.vfs")

Users.list = {}
Users.currentUser = nil

function Users.init()
    -- Create default admin user
    Users.addUser("admin", "love", "home/admin", "admin")
    -- Create guest user
    Users.addUser("guest", "guest", "home/guest", "user")
end

function Users.addUser(name, password, home, role)
    Users.list[name] = {
        name = name,
        password = password, -- In real OS, hash this!
        home = home,
        role = role or "user"
    }
    -- Create home directory
    VFS.mkdir(home)
end

function Users.authenticate(name, password)
    local user = Users.list[name]
    if user and user.password == password then
        Users.currentUser = user
        return true
    end
    return false
end

function Users.getCurrentUser()
    return Users.currentUser
end

function Users.logout()
    Users.currentUser = nil
end

return Users
