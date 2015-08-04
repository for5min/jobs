# vim:ts=4:sw=4:expandtab
require 'chef/node'

unless ARGV[3]
    usage = <<EOF
usage: knife exec replace_fstab NODE OLD_FILESYSTEM NEW_FILESYSTEM

EOF
    abort(usage)
end

node_name = ARGV[2]
old_fs = ARGV[3].downcase
new_fs = ARGV[4].downcase

nodes.find(:name => node_name).each do |n|
    puts "Found " + n.to_s
    normal = n.attributes.normal

    unless normal.has_key?('linux')
        puts "ERROR: no linux attribute"
        next
    end
    unless normal['linux'].has_key?('fstab')
        puts "ERROR: no linux.fstab attribute"
        next
    end
    
    change = false
    normal['linux']['fstab'].each do |fstab|
        unless new_fs.nil?
            if fstab['device'] != old_fs then 
                puts "nothing changed"
                next end
        end
        if  fstab['device'] = new_fs then 
            puts "Change the device attribute"
            change = true end
            
    end

    if change then n.save end
end
exit 0
