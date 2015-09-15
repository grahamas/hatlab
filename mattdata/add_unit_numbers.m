function add_unit_numbers( channel )
unit_list = channel.unit_list;
n_units = length(unit_list);
for i_unit = 1:n_units
    unit = unit_list{i_unit};
    if ~isprop(unit, 'unit_number')
        unit.addprop('unit_number');
    end
    unit.unit_number = i_unit;
end


end

